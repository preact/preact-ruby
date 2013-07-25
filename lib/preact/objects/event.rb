class Preact::Event < Preact::ApiObject
  
  attr_accessor :name, :timestamp, :account

  attr_accessor :note, :links, :external_identifier, :extras

  def add_link(name, href)
    self.links ||= []
    self.links << ActionLink.new({ :name => name, :href => href })
  end

  def as_json(options={})
    {
      :klass     => "actionevent",
      :name      => self.name,
      :timestamp => self.timestamp,
      :account   => self.account,
      :source    => Preact.configuration.user_agent, # version of this logging library

      :note      => self.note,
      :external_identifier => self.external_identifier,
      :extras    => self.extras,
      :links     => self.links.nil? ? nil : self.links.as_json
    }
  end

end