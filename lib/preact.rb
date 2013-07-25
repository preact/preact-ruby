require 'preact/configuration'
require 'preact/client'

require 'preact/objects/api_object'
require 'preact/objects/person'
require 'preact/objects/event'
require 'preact/objects/action_event'
require 'preact/objects/action_link'
require 'preact/objects/account_event'
require 'preact/objects/message'
require 'preact/objects/account'

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
      self.configuration ||= Configuration.new

      yield(configuration) if block_given?
      
      # Configure logger.  Default to use Rails
      self.logger ||= configuration.logger || (defined?(Rails) ? Rails.logger : Logger.new(STDOUT))

      raise StandardError.new "Must specify project code and secret when configuring the Preact api client" unless configuration.valid?

      if defined? Rails
        # never log things if we're in Rails test environment
        configuration.disabled = true if Rails.env.test?
      end
    end

    def log_event(user, event, account = nil)
      # Don't send requests when disabled
      if configuration.disabled?
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
        preact_event = ActionEvent.new({
            :name => event,
            :timestamp => Time.now.to_f
          })
      elsif event.is_a?(Hash)
        preact_event = ActionEvent.new(event)
      elsif event.is_a?(ActionEvent)
        preact_event = event
      else
        raise StandardError.new "Unknown event class, must pass a string event name, event hash or ActionEvent object"
      end

      if account
        # attach the account info to the event
        preact_event.account = configuration.convert_to_account(account).as_json
      end

      person = configuration.convert_to_person(user)
      
      send_log(person.as_json, preact_event.as_json)
    end

    def log_account_event(event, account)
      # Don't send requests when disabled
      if configuration.disabled?
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
      preact_event.account = configuration.convert_to_account(account).as_json
      
      send_log(nil, preact_event.as_json)
    end
      
    def update_person(user)
      # Don't send requests when disabled
      if configuration.disabled?
        logger.info "[Preact] Logging is disabled, not logging event"
        return nil
      elsif user.nil?
        logger.info "[Preact] No person specified, not logging event"
        return nil
      end
      
      person = configuration.convert_to_person(user).as_json

      send_log(person)
    end
    
    # message - a Hash with the following required keys
    #           :subject - subject of the message
    #           :body - body of the message
    #           * any additional keys are used as extra options for the message (:note, etc.)
    # DEPRECATED - DO NOT USE
    def message(user, message = {})
      # Don't send requests when disabled
      if configuration.disabled?
        logger.info "[Preact] Logging is disabled, not logging event"
        return nil
      elsif user.nil?
        logger.info "[Preact] No person specified, not logging event"
        return nil
      end
      
      person = configuration.convert_to_person(user).as_json
      message_obj = Message.new(message).as_json

      send_log(person, message_obj)
    end
    
    protected

    def send_log(person, event=nil)
      psn = person.as_json
      evt = event.nil? ? nil : event.as_json

      if defined?(Preact::Sidekiq)
        Preact::Sidekiq::PreactLoggingWorker.perform_async(psn, evt)
      else
        client.create_event(psn, evt)
      end
    end
    
    def client
      self.default_client ||= Client.new
    end
  end
end