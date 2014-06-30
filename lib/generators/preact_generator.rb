class PreactGenerator < Rails::Generators::Base
  desc "This generator creates a Preact initializer file at config/initializers"
  argument :project_code, :type => :string
  argument :api_secret, :type => :string

  def create_initializer_file
    create_file "config/initializers/preact.rb", <<-FILE
# Preact Logging Configuration
# see documentation about configuration options here: https://github.com/preact/preact-ruby
Preact.configure do |config|
  # all standard configuration is done in the config/preact.yml file
  # if you need to do smarter things during configuration, do them here
end
FILE
  end

  def create_config_file
    create_file "config/preact.yml", <<-FILE
# Preact Logging Configs
production: &defaults

  # your Preact API credentials
  code: "#{project_code}"
  secret: "#{api_secret}"

  # automatically log controller actions for authed users
  # disable this if you want to only log manual events
  autolog: true

  # specify controller#action items that you want to ignore and not log to Preact.
  # default is to not log sessions#create beacuse if you're using Devise, we get that already
  autolog_ignored_actions:
    - "sessions#create"
    - "devise/sessions#create"

  # specify how to retrieve the current user and account from within the application controller
  # you may use either an instance variable (prefixed with @) or a method name
  #current_user_getter: "current_user"
  #current_account_getter: "@current_account"

development:
  <<: *defaults

  # we usually suggest that you use a different project for development, to keep
  # those events separate from production events
  #code: "DEV_CODE"
  #secret: "DEV_SECRET"

  # you may also completely disable event logging in development
  #disabled: false

staging:
  <<: *defaults

  # if you want to log staging events separately as well
  #code: "STAGING_CODE"
  #secret: "STAGING_SECRET"

  # you may also completely disable event logging in staging
  #disabled: false
FILE
  end

end