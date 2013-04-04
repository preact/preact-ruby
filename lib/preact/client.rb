require 'multi_json'
require 'rest_client'

class Preact::Client
    
    def create_event(person, action_event)
    	params = {
        :person => person,
        :event => action_event
      }

      data = post_request("/events", params)
    end

    def update_person(person)
      params = {
        :person => person
      }

      data = post_request("/people", params)
    end
    
    private

    def post_request(method, params={})
      params = prepare_request_params(params)
      
      puts "post_request to #{Preact.configuration.base_uri + method} with #{params.inspect}"
      
      res = RestClient.post Preact.configuration.base_uri + method, params.to_json, :content_type => :json, :accept => :json
      data = MultiJson.decode(res.body)
    end

    def get_request(method, params={})
      params = prepare_request_params(params)
      
      res = RestClient.get Preact.configuration.base_uri + method, { :params => params }
      data = MultiJson.decode(res.body)
    end
    
    def prepare_request_params(params = {})
      params.merge({
        # :user => Preact.configuration.code,
        # :password => Preact.configuration.secret,
        :format => "json"
      })
    end
    

end