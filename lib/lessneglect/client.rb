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

    def tickets
      data = get_request("/tickets")
    end
    
    private

    def post_request(method, params={})
      params = sign_request(params)
      
      puts "post_request method:#{method.inspect} params:#{params.inspect}"
      
      res = RestClient.post LessNeglect.configuration.base_uri + method, params.to_json, :content_type => :json, :accept => :json
      data = MultiJson.decode(res.body)
    end

    def get_request(method, params={})
      params = sign_request(params)
      
      puts "get_request method:#{method.inspect} params:#{params.inspect}"
      
      res = RestClient.get LessNeglect.configuration.base_uri + method, { :params => params }
      data = MultiJson.decode(res.body)
    end
    
    def sign_request(params = {})
      timestamp = Time.now.to_i
      token = rand(36**12).to_s(36)
      signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new('sha256'), LessNeglect.configuration.secret, "#{timestamp}#{token}")

      params.merge({
        :project_code => LessNeglect.configuration.code,
        :signature => signature,
        :token => token,
        :timestamp => timestamp,
        :format => "json"
      })
    end
    

end