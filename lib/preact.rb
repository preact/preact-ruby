require 'preact/configuration'
require 'preact/client'
require 'preact/background_logger'

require 'json'
require 'logger'

module Preact

  class << self
    # A Preact configuration object. Must like a hash and return sensible values for all
    # Preact configuration options. See Preact::Configuration
    attr_accessor :configuration
    
    attr_accessor :default_client

    attr_accessor :logger

    # Call this method to modify the configuration in your initializers
    def configure
      defaults = {}

      # try to use the yml config if we're on rails and it exists
      if defined? ::Rails
        config_yml = File.join(::Rails.root.to_s,"config","preact.yml")
        if File.exists?(config_yml)
          defaults = YAML::load_file(config_yml)[::Rails.env]
        end
      end

      self.configuration ||= Configuration.new(defaults)

      yield(configuration) if block_given?
      
      # Configure logger.  Default to use Rails
      self.logger ||= configuration.logger || (defined?(::Rails) ? ::Rails.logger : Logger.new(STDOUT))

      if defined? ::Rails
        # load the rails extensions
        require 'preact/rails'

        # never log things if we're in Rails test environment
        configuration.disabled = true if ::Rails.env.test?
      end

      if defined? ::Warden
        # if we're using Warden (Devise), load those extensions
        require 'preact/warden'
      end

      if defined? ::Preact::Sidekiq
        # set up the default queue for the sidekiq job
        ::Preact::Sidekiq::PreactLoggingWorker.sidekiq_options(:queue => self.configuration.sidekiq_queue)
      end

    end

    def log_event(user, event, account = nil)
      # Don't send requests when disabled
      if configuration.nil? || configuration.disabled? || !configuration.valid?
        logger.info "[Preact] Logging is disabled, not logging event"
        return nil
      elsif user.nil?
        logger.error "[Preact] No person specified, not logging event"
        return nil
      elsif event.nil?
        logger.error "[Preact] No event specified, not logging event"
        return nil
      end

      if event.is_a?(String)
        preact_event = {
            :name => event,
            :timestamp => Time.now.to_f
          }
      elsif event.is_a?(Hash)
        preact_event = event
      else
        raise StandardError.new "Unknown event class, must pass a string event name or event hash."
      end

      if account
        # attach the account info to the event
        preact_event[:account] = configuration.convert_to_account(account)
      end

      person = configuration.convert_to_person(user)

      preact_event[:klass] = "actionevent"
      
      send_log(person, preact_event)
    end

    def log_account_event(event, account)
      # Don't send requests when disabled
      if configuration.nil? || configuration.disabled? || !configuration.valid?
        logger.info "[Preact] Logging is disabled, not logging event"
        return nil
      elsif account.nil?
        logger.error "[Preact] No account specified, not logging event"
        return nil
      elsif event.nil?
        logger.error "[Preact] No event specified, not logging event"
        return nil
      end

      if event.is_a?(String)
        preact_event = AccountEvent.new({
            :name => event,
            :timestamp => Time.now.to_f
          })
      elsif event.is_a?(Hash)
        preact_event = AccountEvent.new(event)
      elsif event.is_a?(AccountEvent)
        preact_event = event
      else
        raise StandardError.new "Unknown event class, must pass a string event name, event hash or AccountEvent object"
      end

      # attach the account info to the event
      preact_event.account = configuration.convert_to_account(account)
      
      send_log(nil, preact_event.as_json)
    end
      
    def update_person(user)
      # Don't send requests when disabled
      if configuration.nil? || configuration.disabled? || !configuration.valid?
        logger.info "[Preact] Logging is disabled, not logging event"
        return nil
      elsif user.nil?
        logger.info "[Preact] No person specified, not logging event"
        return nil
      end
      
      person = configuration.convert_to_person(user)

      client.update_person(person)
    end
    
    def update_account(account)
      # Don't send requests when disabled
      if configuration.nil? || configuration.disabled? || !configuration.valid?
        logger.info "[Preact] Logging is disabled, not updating account"
        return nil
      elsif account.nil?
        logger.info "[Preact] No account specified, not updating account"
        return nil
      end

      account = configuration.convert_to_account(account)

      client.update_account(account)
    end
    
    def client
      self.default_client ||= Client.new
    end
    
    protected

      def send_log(person, event=nil)
        psn = person.to_hash
        evt = event.nil? ? nil : event.to_hash

        if defined?(Preact::Sidekiq) && (configuration.logging_mode.nil? || configuration.logging_mode == :sidekiq)
          Preact::Sidekiq::PreactLoggingWorker.perform_async(psn, evt)
        else
          # use the background thread logger
          Preact::BackgroundLogger.new.async.perform(psn, evt)
        end
      end

  end
end