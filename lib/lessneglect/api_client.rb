require 'net/http'
require 'uri'
require 'multi_json'

module LessNeglect
  class ApiClient
  
    def initialize
      @base_url = "http://developer.echonest.com/api/v4"
    end
  
    def catalog(id)
      get_request("/catalog/profile", { :id => id })
    end
    
    def catalogs
      get_request("/catalog/list")
    end
    
    def catalog_create(name)
      params = {
        :name => name,
        :type => "song"
      }
      
      data = post_request("/catalog/create", params)
      
      return data["id"]
    end
    
    def catalog_update(id, tracks)
      params = {
        :id => id,
        :data => tracks.map{ |t| t.to_echonest_json("update") }.compact.to_json
      }
      
      data = post_request("/catalog/update", params)
      
      return id
    end
    
    def playlist_create(catalog_id, opts={})
      data = get_request("/playlist/dynamic", {
          :bucket => "id:#{catalog_id}",
          :limit => true
        }.merge(opts))
      
      if song = data["songs"].first
        if track = Track.first("external_identifiers.echonest_song" => song["id"])
          return track, data["session_id"]
        end
      end
      
      data["session_id"]
    end
    
    def playlist_next(playlist_id)
      data = get_request("/playlist/dynamic", { :session_id => playlist_id })
      
      if song = data["songs"].first
        if track = Track.first("external_identifiers.echonest_song" => song["id"])
          return track
        end
      end
    end
    
    def playlist_static_raw(catalog_id, opts={}, limit = 20)
      get_request("/playlist/static", {
          :bucket => "id:#{catalog_id}",
          :limit => true,
          :results => limit
        }.merge(opts))
    end
    
    def playlist_static(catalog_id, opts={}, limit = 20)
      data = self.playlist_static_raw(catalog_id, opts, limit)
      
      track_ids = data["songs"].map{ |s| BSON::ObjectId(s["foreign_ids"].first["foreign_id"].split(":")[2]) }
    end
    
    def song(song_id)
      data = get_request("/song/profile", { :id => song_id })
      data["songs"].first
    end
    
    def terms(artist_name)
      data = get_request("/artist/terms", { :name => artist_name })
      data["terms"]
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