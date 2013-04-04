require 'preact/version'

module Preact
  class Configuration
    
    # Preact credentials
    attr_accessor :code
    attr_accessor :secret
    
    # Default option settings
    attr_accessor :disabled
    attr_accessor :person_builder
    
    # The URL of the API server
    attr_accessor :scheme
    attr_accessor :host
    attr_accessor :base_path
    
    def initialize
      @scheme = 'https'
      @host = 'api.preact.io'
      @base_path = '/api/v2'
      
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
      !!disabled
    end
    
    def user_agent
      @user_agent
    end
    
    def base_uri
      "#{scheme}://#{code}:#{secret}@#{host}#{base_path}"
    end
    
    def convert_to_person(user)
      if person_builder
        if person_builder.respond_to?(:call)
          Person.new(person_builder.call(user))
        else
          raise "person_builder must be callable"
        end
      elsif user.respond_to?(:to_person)
        Person.new(user.to_person)
      elsif user.is_a? Hash
        Person.new(user)
      else
        Person.new(default_user_to_person_hash(user))
      end
    end
    
    private
    
    def default_user_to_person_hash(user)
      # TODO - you should update this to build a full LN Person object
      # with the data in your User model
    
      {
        :name => user.name,
        :email => user.email,
        :external_identifer => user.id,
        :properties => {
          :account_level => (user.account_level if user.respond_to?(:account_level)),
          :is_paying => (user.paying? if user.respond_to?(:paying)),
          :created_at => user.created_at.to_i
        }
      }
    end

  end
end