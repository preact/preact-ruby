class Preact::Person < Preact::ApiObject
    
  attr_accessor :name, :email, :external_identifier, :properties, :uid, :created_at
    
  def as_json(options={})
    d = {
      :name                => self.name,
      :email               => self.email,
      :uid                 => self.uid || self.external_identifier,
      :created_at          => self.created_at ? self.created_at.to_i : nil,
      :properties          => self.properties || {}
    }
  end
    
end