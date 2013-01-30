require 'lessneglect/api_helpers'
require 'lessneglect/methods'

class LessNeglectApi

	class Client

		def initialize(opts = {})
	      @project_code = opts[:code]
	      @project_secret = opts[:secret]

	      unless @project_code && @project_secret
	        raise StandardError.new "Must specify project code and secret when initalizing the ApiClient"
	      end

	      #@base_url = "https://#{@project_code}:#{@project_secret}@api.lessneglect.com/api/v2"
	      @base_url = "http://#{@project_code}:#{@project_secret}@test.lessneglect.com:4000/api/v2"

	    end

	end

end