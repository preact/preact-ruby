require 'net/http'
require 'uri'
require 'multi_json'

class LessNeglectClient
  private

    def post_request(method, params={})
      params = sign_request(params)
      
      uri = URI.parse(@base_url + method)
      
      res = Net::HTTP.post_form(uri, params)
      data = MultiJson.decode(res.body)
    end

    def get_request(method, params={})
      params = sign_request(params)
    
      uri = URI.parse(@base_url + method + "?" + params.to_query)
      
      res = Net::HTTP.get_response(uri)
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