Preact Logging API Ruby Client
===
Allow your Ruby app to easily submit server-side messages and events to Preact.

Installation
---

In your Gemfile:

```ruby
gem 'preact'
```

Configuration
---

Configure Preact with your API credentials. You can find your Preact credentials on the [API settings page](https://secure.preact.io/settings/api) (This should go in an initializer file named `/config/initializers/preact.rb` in Rails applications)

```ruby
Preact.configure do |config|
  config.code   = 'abcdefg'           # required
  config.secret = '1234asdfasdf1234'  # required
  
  # Disable in Rails development environments
  # config.disabled = Rails.env.development?
  
  # Uncomment this this line to customize the data sent with your Person objects.
  # Your custom procedure should return a Hash of attributes
  # config.person_builder = lambda {|user| {:keys => :values}}
  
  # Defaults to Rails.logger or Logger.new(STDOUT). Set to Logger.new('/dev/null') to disable logging.
  # config.logger = Logger.new('/dev/null')  
end
```

Usage
---

The Preact.log_event method takes two required parameters and an optional third parameter.

You must pass both a `person` and an `event`.

The `person` parameter may be either a Hash or an ActiveRecord model (see below). 

The `event` parameter may be either a String if you just are passing the event name, or it may be a Hash of the event object including other properties like `revenue`, `note` and a nested `extras` hash.

```ruby
person = {
  :name => "Christopher Gooley",
  :email => "gooley@foliohd.com",
  :uid => "gooley",
  :properties => {
    :subscription_level => 4,
    :subscription_level_name => "Pro",
    :is_paying => true,
    :created_at => 1347060566
    :twitter => "gooley"
  }
}

#common event examples:
Preact.log_event(person, 'logged-in')
Preact.log_event(person, 'upgraded')
Preact.log_event(person, { :name => 'processed:payment', :revenue => 900 }) # revenue specified in cents
Preact.log_event(person, { :name => 'uploaded:file', :note => "awesome_resume.pdf" })

Preact.log_event(person, {
    :name => 'purchased:item',
    :note => "black shoes", 
    :revenue => 2500, 
    :extras => {
      :category => "shoes",
      :size => "13",
      :color => "blue"
    })
```

If you are a Preact B2B user, you should also log the `account` that this event occurred within. You can do that by passing a third parameter to Preact.log_event to specify the account information. The preferred method for `account` is to use the ActiveRecord integration outlined below.

```ruby
Preact.log_event(
          { :email => "bob@honda.com", :name => "Bob Smith" }, # person
          { :name => 'uploaded:file', :note => "awesome_resume.pdf" }, # event
          { :id => 1234, :name => "Honda"} # account
        )
```

ActiveRecord Integration
---
In your `User` model, you can define a `to_preact` method returning a Hash. Preact will detect and use this method on users passed to its logging events.

```ruby
class User < ActiveRecord::Base
  def to_preact
    {
      :name => self.name,
      :email => self.email,
      :uid => self.id,
      :properties => {
        :account_level => self.account_level,
        :is_paying => self.paying_customer?,
        :created_at => self.created_at.to_i
      }
    }
  end
end
```

```ruby
Preact.log_event(@current_user, 'restored_answer_data') 
Preact.log_event(@current_user, { :name => 'updated-profile', :extras => {:twitter => "@gooley"} })
```

Likewise, if you are a Preact B2B user, you can define the `to_preact` method on the model that defines your Account grouping. For instance, if you attach your Users into "Projects" you would add the `to_preact` method into your Project model.

```ruby
class Project < ActiveRecord::Base
  def to_preact
    {
      :name => self.name,
      :id => self.id
    }
  end
end
```

Then, you just pass that model to the log_event method and we will associate the user's action with that account.

```ruby
Preact.log_event(@current_user, 'restored_answer_data', @current_project) 
Preact.log_event(@current_user, { :name => 'updated-profile', :extras => {:twitter => "@gooley"} }, @current_project)
```

Sidekiq Integration
---
Using [Sidekiq](http://sidekiq.org) for background processing? That's the best way to log data to Preact so it's not done in-process. 

All you need to do is add `require 'preact/sidekiq'` at the top of your `preact.rb` initializer and we'll take it from there. Jobs will be placed on the :default queue.

Devise / Warden Integration
--
Automatically log your login/logout events by including this in your `preact.rb` initializer. Just put it under the Preact config block.

```ruby
# after-auth hook to log the login
Warden::Manager.after_authentication do |user,auth,opts|
  Preact.log_event(user, "logged-in")
end
Warden::Manager.before_logout do |user,auth,opts|
  Preact.log_event(user, "logged-out")
end
```


Copyright (c) 2011-2013 Christopher Gooley, Preact / Less Neglect, Inc. See LICENSE.txt for further details.

Thanks to [Zach Millman](https://github.com/zmillman) for many contributions.
