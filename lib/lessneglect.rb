require 'lessneglect/api_helpers'
require 'lessneglect/methods'

require 'lessneglect/objects/api_object'
require 'lessneglect/objects/person'
require 'lessneglect/objects/action'
require 'lessneglect/objects/message'


class LessNeglectApi

	class Client

		def initialize(opts = {})
	      @base_url = "http://test.lessneglect.com:4000/api/v1"

	      @project_code = opts[:code]
	      @project_secret = opts[:secret]

	      unless @project_code && @project_secret
	        raise StandardError.new "Must specify project_code and project_secret when initalizing the ApiClient"
	      end
	    end

	end

end