class Preact::Account < Preact::ApiObject
    
  attr_accessor :id, :name
  attr_accessor :license_status, :license_mrr, :license_type, :license_count, :license_value, :license_duration, :license_renewal
    
  def as_json(options={})
    {
      :name               => self.name,
      :external_identifier=> self.id,

      :license_type       => self.license_type,
      :license_count      => self.license_count,
      :license_renewal    => self.license_renewal,
      :license_value      => self.license_value,
      :license_mrr        => self.license_mrr,
      :license_duration   => self.license_duration,
      :license_status     => self.license_status
    }
  end
    
end