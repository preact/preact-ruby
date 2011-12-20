require 'lessneglect/api_helpers'
require 'lessneglect/methods'

class LessNeglectClient

	def initialize(opts = {})
      @base_url = "http://test.lessneglect.com:4000/api/v1"

      @project_code = opts[:code]
      @project_secret = opts[:secret]

      unless @project_code && @project_secret
        raise StandardError.new "Must specify project_code and project_secret when initalizing the ApiClient"
      end
    end

end