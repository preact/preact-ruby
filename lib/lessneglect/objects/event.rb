class LessNeglect::Event < LessNeglect::ApiObject
  
  attr_accessor :name, :magnitude

  def as_json(options={})
    {
      :name      => self.name,
      :magnitude => self.magnitude,
      :source    => LessNeglect.configuration.user_agent # version of this logging library
    }
  end

end