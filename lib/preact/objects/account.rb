class Preact::Account < Preact::ApiObject
    
  attr_accessor :id, :name
    
  def as_json(options={})
    {
      :name               => self.name,
      :id                 => self.id
    }
  end
    
end