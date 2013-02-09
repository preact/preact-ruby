class LessNeglect::Person < LessNeglect::ApiObject
    
  attr_accessor :name, :email, :external_identifier, :properties
    
  def as_json(options={})
    {
      :name                => self.name,
      :email               => self.email,
      :external_identifier => self.external_identifier,
      :properties          => self.properties,
    }
  end
    
end