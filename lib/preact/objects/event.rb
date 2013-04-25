class Preact::Event < Preact::ApiObject
  
  attr_accessor :name, :timestamp

  def as_json(options={})
    {
      :name      => self.name,
      :timestamp => self.timestamp,
      :source    => Preact.configuration.user_agent # version of this logging library
    }
  end

end