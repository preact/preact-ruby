require 'preact/configuration'
require 'preact/client'

require 'preact/objects/api_object'
require 'preact/objects/person'
require 'preact/objects/event'
require 'preact/objects/action_event'
require 'preact/objects/message'

module Preact

  class << self
    # A Preact configuration object. Must like a hash and return sensible values for all
    # Preact configuration options. See Preact::Configuration
    attr_accessor :configuration
    
    attr_accessor :default_client

    # Call this method to modify the configuration in your initializers
    def configure
      self.configuration ||= Configuration.new

      yield(configuration) if block_given?
      
      raise StandardError.new "Must specify project code and secret when configuring the Preact api client" unless configuration.valid?
    end
    
    def log_event(user, event_name, extras = {})
      # Don't send requests when disabled
      return if configuration.disabled?
      return if user.nil?
 
      person = configuration.convert_to_person(user)
      event = ActionEvent.new({
          :name => event_name
        }.merge(extras))
 
      client.create_event(person, event)
    end
      
    def update_person(user)
      # Don't send requests when disabled
      return if configuration.disabled?
      return if user.nil?
      
      client.update_person(configuration.convert_to_person(user))
    end
    
    # message - a Hash with the following required keys
    #           :subject - subject of the message
    #           :body - body of the message
    #           * any additional keys are used as extra options for the message (:note, etc.)
    def message(user, message = {})
      # Don't send requests when disabled
      return if configuration.disabled?
      return if user.nil?
      
      person = configuration.convert_to_person(user)
      message_obj = Message.new(message)
      
      client.create_event(person, message_obj)
    end
    
    protected
    
    def client
      self.default_client ||= Client.new
    end
  end
end