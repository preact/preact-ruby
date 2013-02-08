require 'lessneglect/configuration'
require 'lessneglect/client'

require 'lessneglect/objects/api_object'
require 'lessneglect/objects/person'
require 'lessneglect/objects/event'
require 'lessneglect/objects/action_event'
require 'lessneglect/objects/message'

module LessNeglect

  class << self
    # A LessNeglect configuration object. Must like a hash and return sensible values for all
    # LessNeglect configuration options. See LessNeglect::Configuration
    attr_accessor :configuration
    
    attr_accessor :default_client

    # Call this method to modify the configuration in your initializers
    def configure
      self.configuration ||= Configuration.new

      yield(configuration) if block_given?
      
      raise StandardError.new "Must specify project code and secret when configuring the LessNeglect api client" unless configuration.valid?
    end
    
    def log_event(user, event_name, extras = {})
      # Don't send requests when disabled
      return if configuration.disabled?
      return if user.nil?
 
      person = configuration.convert_to_person(user)
 
      event = ActionEvent.new({
          :name => event_name
        }.merge(extras))
 
      client.create_action_event(person, event)
    end
      
    def update_person(user)
      # Don't send requests when disabled
      return if configuration.disabled?
      return if user.nil?
      
      client.update_person(configuration.convert_to_person(user))
    end
    
    protected
    
    def client
      self.default_client ||= Client.new
    end
  end
end