class LessNeglectApi
  class Client
	
    def create_message(person, message)
      return false if person.nil? || message.nil?
      message[:klass] = "message"
      message[:timestamp] ||= Time.now.to_f

      params = {
        :person => person,
        :event => message
      }
      
      data = post_request("/events", params)
    end
    
    def create_event(person, event, custom = nil)
      return false if person.nil? || event.nil?

      if event.is_a?(String)
        # convert into a hash with the name of the event
        event = {
          :name => event
        }
      elsif !event.is_a?(Hash)
        # don't do anything if it's not a string or hash
        return false
      end

      event[:timestamp] ||= Time.now.to_f

      if custom && custom.is_a?(Hash)
        event[:extras] ||= {}
        event[:extras].merge!(custom)
      end

    	params = {
        :person => person,
        :event => event
      }

      data = post_request("/events", params)
    end

    def update_person(person)
      params = {
        :person => person.as_json
      }

      data = post_request("/people", params)
    end

  end
end