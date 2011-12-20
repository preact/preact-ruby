class LessNeglectClient
	
    def message_create(params = {})
      data = post_request("/messages", params)
    end
    
    def action_create(params = {})
      data = post_request("/actions", params)
    end

    def tickets
      data = get_request("/tickets")
    end

end