require 'multi_json'
require 'rest_client'

class LessNeglectApi
  class Client
    private

      def post_request(method, params={})
        params = sign_request(params)
        
        res = RestClient.post @base_url + method, params.to_json, :content_type => :json, :accept => :json
        data = MultiJson.decode(res.body)
      end

      def get_request(method, params={})
        params = sign_request(params)
      
        res = RestClient.get @base_url + method, { :params => params }
        data = MultiJson.decode(res.body)
      end

      def sign_request(params = {})
        timestamp = Time.now.to_i
        token = rand(36**12).to_s(36)
        signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new('sha256'), @project_secret, "#{timestamp}#{token}")

        params.merge({
          :project_code => @project_code,
          :signature => signature,
          :token => token,
          :timestamp => timestamp,
          :format => "json"
        })
      end
  end
end