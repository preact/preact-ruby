class LessNeglect::Message < LessNeglect::Event
  
  attr_accessor :subject, :body

  def as_json(options={})
    super(options).merge({
      :klass => "message",
      :subject => self.subject,
      :body => self.body
    })
  end
  
end