class LessNeglectApi
	class Action < ApiObject

		attr_accessor :name, :note, :email_subject
    attr_accessor :links

    def add_link(name, href)
      self.links ||= []
      self.links << ActionLink.new({ :name => name, :href => href })
    end

    def as_json(options={})
      {
        :name => self.name,
        :note => self.note,
        :email_subject => self.email_subject,
        :links => self.links.nil? ? nil : self.links.as_json
      }.as_json(options)
    end

	end

	class ActionLink < ApiObject

		attr_accessor :name, :href

	end
end