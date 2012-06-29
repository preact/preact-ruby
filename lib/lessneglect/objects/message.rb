class LessNeglectApi
  class Message < Event

    attr_accessor :subject, :body

    def as_json(options={})
      super.merge({
        :klass => "message",
        :subject => self.subject,
        :body => self.body
      }).as_json(options)
    end

  end
end