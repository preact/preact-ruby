require 'lessneglect/configuration'
require 'lessneglect/client'

require 'lessneglect/objects/api_object'
require 'lessneglect/objects/person'
require 'lessneglect/objects/event'
require 'lessneglect/objects/action_event'
require 'lessneglect/objects/message'

require 'logger'

module LessNeglect

  class << self
    # A LessNeglect configuration object. Must like a hash and return sensible values for all
    # LessNeglect configuration options. See LessNeglect::Configuration
    attr_accessor :configuration
    
    attr_accessor :default_client
    
    attr_accessor :logger

    # Call this method to modify the configuration in your initializers
    def configure
      self.configuration ||= Configuration.new

      yield(configuration) if block_given?
      
      # Configure logger.  Default to use Rails
      self.logger ||= configuration.logger || (defined?(Rails) ? Rails.logger : Logger.new(STDOUT))
      
      raise StandardError.new "Must specify project code and secret when configuring the LessNeglect api client" unless configuration.valid?
    end
    
    def log_event(user, event_name, extras = {})
      # Don't send requests when disabled
      if configuration.disabled?
        logger.info "[LessNeglect] Neglect is disabled, not logging event"
        return nil
      elsif user.nil?
        logger.info "[LessNeglect] No person specified, not logging event"
        return nil
      end
 
      person = configuration.convert_to_person(user)
      event = ActionEvent.new({
          :name => event_name
        }.merge(extras))
 
      client.create_event(person, event)
      logger.info "[LessNeglect] Logged event #{event_name} for person \"#{person.external_identifier}\""
    end
      
    def update_person(user)
      # Don't send requests when disabled
      if configuration.disabled?
        logger.info "[LessNeglect] Neglect is disabled, not logging event"
        return nil
      elsif user.nil?
        logger.info "[LessNeglect] No person specified, not logging event"
        return nil
      end
      
      person = configuration.convert_to_person(user)
      
      client.update_person(person)
      logger.info "[LessNeglect] Logged event #{event_name} for person \"#{person.external_identifier}\""
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