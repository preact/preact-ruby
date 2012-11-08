class LessNeglectApi
	class ActionEvent < Event

    attr_accessor :note, :links, :external_identifier, :extras

    def add_link(name, href)
      self.links ||= []
      self.links << ActionLink.new({ :name => name, :href => href })
    end

    def as_json(options={})
      super.merge({
        :klass => "actionevent",
        :note => self.note,
        :external_identifier => self.external_identifier,
        :extras => self.extras,
        :links => self.links.nil? ? nil : self.links.as_json
      }).as_json(options)
    end

	end

	class ActionLink < ApiObject

		attr_accessor :name, :href

	end
end