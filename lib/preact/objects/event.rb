class Preact::Event < Preact::ApiObject
  
  attr_accessor :name, :timestamp, :account

  attr_accessor :note, :links, :external_identifier, :target_id, :revenue, :extras
  attr_accessor :thumb_url, :link_url

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
      :revenue   => self.revenue,
      :source    => Preact.configuration.user_agent, # version of this logging library

      :note      => self.note,
      :external_identifier => self.target_id || self.external_identifier,
      :extras    => self.extras,
      :links     => self.links.nil? ? nil : self.links.as_json,
      :thumb_url => self.thumb_url,
      :link_url  => self.link_url
    }
  end

end