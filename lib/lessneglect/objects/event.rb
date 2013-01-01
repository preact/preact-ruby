class LessNeglectApi
	class Event < ApiObject

		attr_accessor :name, :magnitude

    def as_json(options={})
      {
        :name => self.name,
        :magnitude => self.magnitude,
        :source => "lessneglect-ruby:0.3.5" # version of this logging library
      }.as_json(options)
    end

	end
end