class PreactGenerator < Rails::Generators::Base
  desc "This generator creates a Preact initializer file at config/initializers"
  argument :project_code, :type => :string
  argument :api_secret, :type => :string

  def create_initializer_file
    create_file "config/initializers/preact.rb", <<-FILE
# Preact Logging Configuration
# see documentation about configuration options here: https://github.com/preact/preact-ruby
Preact.configure do |config|
  config.code   = "#{project_code}"
  config.secret = "#{api_secret}"

  # automatically log controller actions for authed users
  # disable this if you want to only log manual events
  config.autolog = true 

  # disable in Rails non-production environments
  # uncomment this if you don't want to log development activities
  #config.disabled = !Rails.env.production?
end
FILE
  end

end