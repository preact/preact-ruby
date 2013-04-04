class Preact::Person < Preact::ApiObject
    
  attr_accessor :name, :email, :external_identifier, :properties, :uid
    
  def as_json(options={})
    {
      :name                => self.name,
      :email               => self.email,
      :uid                 => self.uid || self.external_identifier,
      :properties          => self.properties
    }
  end
    
end