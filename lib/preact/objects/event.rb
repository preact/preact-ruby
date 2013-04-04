class Preact::Event < Preact::ApiObject
  
  attr_accessor :name, :magnitude, :timestamp

  def as_json(options={})
    {
      :name      => self.name,
      :magnitude => self.magnitude,
      :timestamp => self.timestamp,
      :source    => Preact.configuration.user_agent # version of this logging library
    }
  end

end