module Preact
	class ActionLink < ApiObject

		attr_accessor :name, :href

		def as_json
		  {
		    :name => self.name,
		    :href => self.href
		  }
		end

	end
end