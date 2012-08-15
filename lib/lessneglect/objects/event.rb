class LessNeglectApi
	class Event < ApiObject

		attr_accessor :name, :magnitude

    def as_json(options={})
      {
        :name => self.name,
        :magnitude => self.magnitude
      }.as_json(options)
    end

	end
end