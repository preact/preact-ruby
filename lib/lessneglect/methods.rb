class LessNeglectApi::Client
	
    def create_message(person, message)
      params = {
        :person => person.as_json,
        :event => message.as_json
      }
      
      data = post_request("/events", params)
    end
    
    def create_action_event(person, action_event)
    	params = {
        :person => person.as_json,
        :event => action_event.as_json
      }

      data = post_request("/events", params)
    end

    def update_person(person)
      params = {
        :person => person.as_json
      }

      data = post_request("/people", params)
    end

    def tickets
      data = get_request("/tickets")
    end

end