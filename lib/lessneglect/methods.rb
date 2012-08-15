class LessNeglectApi::Client
	
    def message_create(person, message)
      params = {
        :person => person.as_json,
        :message => message.as_json
      }
      
      data = post_request("/messages", params)
    end
    
    def action_create(person, action)
    	params = {
        :person => person.as_json,
        :person_action => action.as_json
      }

      data = post_request("/actions", params)
    end

    def tickets
      data = get_request("/tickets")
    end

end