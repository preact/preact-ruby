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
    
    # Logger settings
    attr_accessor :logger
    
    # The URL of the API server
    attr_reader :scheme
    attr_reader :host
    attr_reader :base_path
    
    def initialize
      @scheme = 'https'
      @host = 'api.preact.io'
      @base_path = '/api/v2'

      @autolog = false
      @autolog_ignored_actions = []
      @disabled = false
      @person_builder = nil
      
      @user_agent = "ruby-preact:#{Preact::VERSION}"
    end
    
    def valid?
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
    
    def convert_to_person(user)
      if person_builder
        if person_builder.respond_to?(:call)
          Person.new(person_builder.call(user))
        else
          raise "person_builder must be callable"
        end
      elsif user.respond_to?(:to_preact)
        Person.new(user.to_preact)
      elsif user.is_a? Hash
        Person.new(user)
      else
        Person.new(default_user_to_preact_hash(user))
      end
    end

    def convert_to_account(account)
      if account_builder
        if account_builder.respond_to?(:call)
          Account.new(account_builder.call(account))
        else
          raise "account_builder must be callable"
        end
      elsif account.respond_to?(:to_preact)
        Account.new(account.to_preact)
      elsif account.is_a? Hash
        Account.new(account)
      else
        Account.new(default_account_to_preact_hash(account))
      end
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