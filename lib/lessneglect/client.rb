require 'multi_json'
require 'rest_client'

class LessNeglect::Client
	
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
    
    private

    def post_request(method, params={})
      params = prepare_request_params(params)
      
      res = RestClient.post LessNeglect.configuration.base_uri + method, params.to_json, :content_type => :json, :accept => :json
      data = MultiJson.decode(res.body)
    end

    def get_request(method, params={})
      params = prepare_request_params(params)
      
      res = RestClient.get LessNeglect.configuration.base_uri + method, { :params => params }
      data = MultiJson.decode(res.body)
    end
    
    def prepare_request_params(params = {})
      params.merge({
        # :user => LessNeglect.configuration.code,
        # :password => LessNeglect.configuration.secret,
        :format => "json"
      })
    end
    

end