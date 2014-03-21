require 'multi_json'
require 'rest_client'

module Preact
  class Client
    
    def create_event(person, event)
    	params = {
        :person => Preact.configuration.prepare_person_hash(person),
        :event => Preact.configuration.prepare_event_hash(event)
      }

      if params[:event][:account]
        params[:event][:account] = Preact.configuration.prepare_account_hash(params[:event][:account])
      end
      
      data = post_request("/events", params)
    end

    def update_person(person)
      params = {
        :person => Preact.configuration.prepare_person_hash(person)
      }

      data = post_request("/people", params)
    end

    def update_account(account)

      params = {
        :account => Preact.configuration.prepare_account_hash(account)
      }

      data = post_request("/accounts", params)
    end
    
    private

    def post_request(method, params={})
      params = prepare_request_params(params)
      
      Preact.logger.debug "[Preact] post_request to #{Preact.configuration.base_uri + method} with #{params.inspect}"
      
      res = RestClient::Request.execute({
            :method => :post, 
            :url => Preact.configuration.base_uri + method, 
            :payload => params,
            :headers => { :content_type => :json, :accept => :json },
            :open_timeout => Preact.configuration.request_timeout,
            :timeout => Preact.configuration.request_timeout
          })
      data = MultiJson.decode(res.body)
    end

    def get_request(method, params={})
      params = prepare_request_params(params)

      Preact.logger.debug "[Preact] get_request to #{Preact.configuration.base_uri + method} with #{params.inspect}"

      res = RestClient::Request.execute({
            :method => :get, 
            :url => Preact.configuration.base_uri + method, 
            :params => params,
            :headers => { :content_type => :json, :accept => :json },
            :open_timeout => Preact.configuration.request_timeout,
            :timeout => Preact.configuration.request_timeout
          })

      data = MultiJson.decode(res.body)
    end
    
    def prepare_request_params(params = {})
      params.merge({
        :format => "json",
        :source => Preact.configuration.user_agent
      })
    end
    
  end
end