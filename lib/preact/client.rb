require 'multi_json'
require 'rest_client'

module Preact
  class Client
    
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

    def update_account(account)
      params = {
        :account => account
      }

      data = post_request("/accounts", params)
    end
    
    private

    def post_request(method, params={})
      params = prepare_request_params(params)
      
      Preact.logger.debug "[Preact] post_request to #{Preact.configuration.base_uri + method} with #{params.inspect}"
      
      res = RestClient.post Preact.configuration.base_uri + method, params.to_json, :content_type => :json, :accept => :json
      data = MultiJson.decode(res.body)
    end

    def get_request(method, params={})
      params = prepare_request_params(params)

      Preact.logger.debug "[Preact] get_request to #{Preact.configuration.base_uri + method} with #{params.inspect}"

      res = RestClient.get Preact.configuration.base_uri + method, { :params => params }
      data = MultiJson.decode(res.body)
    end
    
    def prepare_request_params(params = {})
      params.merge({
        :format => "json"
      })
    end
    
  end
end