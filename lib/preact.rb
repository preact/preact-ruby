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

      if defined? Rails
        # never log things if we're in Rails test environment
        configuration.disabled = true if Rails.env.test?
      end
    end
    
    def log_event(user, event_name, extras = {})
      # Don't send requests when disabled
      return if configuration.disabled?
      return if user.nil?
 
      person = configuration.convert_to_person(user).as_json
      event = ActionEvent.new({
          :name => event_name,
          :timestamp => Time.now.to_f
        }.merge(extras)).as_json

      send_log(person, event)
    end
      
    def update_person(user)
      # Don't send requests when disabled
      return if configuration.disabled?
      return if user.nil?
      
      person = configuration.convert_to_person(user).as_json

      send_log(person)
    end
    
    # message - a Hash with the following required keys
    #           :subject - subject of the message
    #           :body - body of the message
    #           * any additional keys are used as extra options for the message (:note, etc.)
    def message(user, message = {})
      # Don't send requests when disabled
      return if configuration.disabled?
      return if user.nil?
      
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