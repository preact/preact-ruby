require 'multi_json'
require 'rest_client'

class LessNeglectApi
  class Client

    def post_request(method, params={})
      res = RestClient.post @base_url + method, params.to_json, :content_type => :json, :accept => :json
      data = MultiJson.decode(res.body)
    end

    def get_request(method, params={})
      res = RestClient.get @base_url + method, { :params => params }
      data = MultiJson.decode(res.body)
    end
    
  end
end