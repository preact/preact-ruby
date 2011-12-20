require 'net/http'
require 'uri'
require 'multi_json'

class LessNeglect
  class ApiClient
  
    def initialize
      @base_url = "http://api.lessneglect.com/api/v1"
    end
    
    def catalog_update(id, tracks)
      params = {
        :id => id,
        :data => tracks.map{ |t| t.to_echonest_json("update") }.compact.to_json
      }
      
      data = post_request("/catalog/update", params)
      
      return id
    end
    
    def artist(artist_name)
      data = get_request("/artist/profile", { :name => artist_name, :bucket => "terms", "bucket" => "images" })
      data["artist"]
    end
    
    private
  
      def post_request(method, params={})
        params.merge!({
          :api_key => @api_key
        })
        
        uri = URI.parse(@base_url + method)
        
        res = Net::HTTP.post_form(uri, params)
        data = MultiJson.decode(res.body)
        
        if data["response"]["status"]["message"] == "Success"
          return data["response"]
        else
          raise StandardError.new data["response"]["status"]["message"]
        end
      end
  
      def get_request(method, params={})
        params.merge!({
          :api_key => @api_key
        })
      
        uri = URI.parse(@base_url + method + "?" + params.to_query)
        
        res = Net::HTTP.get_response(uri)
        data = MultiJson.decode(res.body)
        
        if data["response"]["status"]["message"] == "Success"
          return data["response"]
        else
          raise StandardError.new data["response"]["status"]["message"]
        end        
      end
  
  end
end