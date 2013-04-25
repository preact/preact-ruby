class Preact::Event < Preact::ApiObject
  
  attr_accessor :name, :timestamp, :account

  def as_json(options={})
    {
      :name      => self.name,
      :timestamp => self.timestamp,
      :account   => self.account,
      :source    => Preact.configuration.user_agent # version of this logging library
    }
  end

end