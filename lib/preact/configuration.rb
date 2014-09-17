require 'preact/version'

module Preact
  class Configuration
    
    # Preact credentials
    attr_accessor :code
    attr_accessor :secret
    
    # Default option settings
    attr_accessor :disabled
    attr_accessor :person_builder
    attr_accessor :account_builder
    attr_accessor :autolog
    attr_accessor :autolog_ignored_actions
    attr_accessor :sidekiq_queue
    attr_accessor :request_timeout
    attr_accessor :logging_mode
    attr_accessor :inject_javascript

    attr_accessor :current_user_getter
    attr_accessor :current_account_getter
    
    # Logger settings
    attr_accessor :logger
    
    # The URL of the API server
    attr_accessor :scheme
    attr_accessor :host
    attr_accessor :base_path
    
    def initialize(defaults={})
      @scheme = 'https'
      @host = 'api.preact.io'
      @base_path = '/api/v2'

      @autolog = false
      @autolog_ignored_actions = []
      @disabled = false
      @person_builder = nil

      @logging_mode = nil
      @sidekiq_queue = :default
      @request_timeout = 5

      @inject_javascript = false

      @current_user_getter = :current_user
      @current_account_getter = nil
      
      @user_agent = "ruby-preact:#{Preact::VERSION}"

      if defaults && defaults.is_a?(Hash)
        defaults.each do |k,v|
          instance_variable_set("@#{k}", v) unless v.nil?
        end
      end
    end
    
    def valid?
      # we require both the API keys
      code && secret
    end
    
    def enabled?
      !disabled
    end
    
    def disabled?
      disabled == true
    end
    
    def user_agent
      @user_agent
    end
    
    def base_uri
      "#{scheme}://#{code}:#{secret}@#{host}#{base_path}"
    end

    def inject_javascript?
      inject_javascript == true
    end

    def autolog_enabled?
      autolog == true
    end

    def autolog_should_log?(controller, action)
      # check to see if we're ignoring this action
      if autolog_ignored_actions && autolog_ignored_actions.is_a?(Array)

        # check to see if we've ignored this specific action
        return false if autolog_ignored_actions.include?("#{controller}##{action}")

        # check to see if we've ignored all actions from this controller
        return false if autolog_ignored_actions.include?("#{controller}#*")

      end

      true
    end
    
    def get_current_user(target)
      return nil if current_user_getter.nil?

      if current_user_getter.to_s.starts_with?("@")
        # instance var
        target.instance_variable_get(current_user_getter) rescue nil
      else
        target.send(current_user_getter) rescue nil
      end
    end

    def get_current_account(target)
      return nil if current_user_getter.nil?

      if current_account_getter.to_s.starts_with?("@")
        # instance var
        target.instance_variable_get(current_account_getter) rescue nil
      else
        target.send(current_account_getter) rescue nil
      end
    end

    def convert_to_person(user)
      return nil if user.nil?

      if person_builder
        if person_builder.respond_to?(:call)
          hash = person_builder.call(user)
        else
          raise "person_builder must be callable"
        end
      elsif user.respond_to?(:to_preact)
        hash = user.to_preact
      elsif user.is_a? Hash
        hash = user
      else
        hash = default_user_to_preact_hash(user)
      end

      hash
    end

    def convert_to_account(account)
      return nil if account.nil?
      
      if account_builder
        if account_builder.respond_to?(:call)
          hash = account_builder.call(account)
        else
          raise "account_builder must be callable"
        end
      elsif account.respond_to?(:to_preact)
        hash = account.to_preact
      elsif account.is_a? Hash
        hash = account
      else
        hash = default_account_to_preact_hash(account)
      end

      hash
    end

    def prepare_person_hash(person)
      return nil if person.nil?

      if external_id = person[:external_identifier] || person["external_identifier"]
        person[:uid] ||= external_id
        person.delete(:external_identifier)
        person.delete("external_identifier")
      end

      if created_at = person[:created_at] || person["created_at"]
        if created_at.respond_to?(:to_i)
          created_at = created_at.to_i
        end

        person[:created_at] = created_at
        person.delete("created_at")
      end

      person
    end

    def prepare_account_hash(account)
      # id for account should actually be passed as external_identifier
      # make that correction here before sending (LEGACY SUPPORT)
      external_id = account[:external_identifier] || account["external_identifier"]
      if account_id = account[:id] || account["id"]
        if external_id.nil?
          account[:external_identifier] = account_id
          account.delete(:id)
          account.delete("id")
        end
      end

      account
    end

    def prepare_event_hash(event)
      event[:source] = Preact.configuration.user_agent
      event
    end
    
    private
    
    def default_user_to_preact_hash(user)
      {
        :name => user.name,
        :email => user.email,
        :uid => user.id,
        :created_at => (user.created_at.to_i if user.respond_to?(:created_at))
      }
    end

    def default_account_to_preact_hash(account)
      {
        :id => account.id,
        :name => (account.name if account.respond_to?(:name))
      }
    end

  end
end