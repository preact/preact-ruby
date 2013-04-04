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

Configure Preact with your API credentials. (This should go in an initializer file named `/config/initializers/preact.rb` in Rails applications)

```ruby
Preact.configure do |config|
  config.code   = 'abcdefg'           # required
  config.secret = '1234asdfasdf1234'  # required
  
  # Disable in Rails development environments
  # config.disabled = (Rails.env != "development")
  
  # Uncomment this this line to customize the data sent with your Person objects.
  # Your procedure should return a Hash of attributes
  # config.person_builder = lambda {|user| {:keys => :values}}
end
```

Usage
---

```ruby
person = {
  :name => "Christopher Gooley",
  :email => "gooley@foliohd.com",
  :uid => "gooley",
  :properties => {
    :account_level => "Pro",
    :is_paying => true,
    :created_at => 1347060566
    :twitter => "gooley"
  }
}

#common event examples:
Preact.log_event(person, 'logged-in')
Preact.log_event(person, 'upgraded')
Preact.log_event(person, 'processed:payment', :revenue => 900) # revenue specified in cents
Preact.log_event(person, "uploaded:file", :note => "awesome_resume.pdf")

Preact.log_event(person, 'purchased:item', {
    :note => "black shoes", 
    :revenue => 2500, 
    :extras => {
      :size => "13",
      :color => "blue"
    })
```

ActiveRecord Integration
---
In your `User` model, you can define a `to_person` method returning a Hash. Preact will detect and use this method on users passed to its logging events.

```ruby
class User < ActiveRecord::Base
  def to_person
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
Preact.log_event(User.find(1), 'restored_answer_data')
Preact.log_event(User.find(1), 'updated-profile', :extras => {:twitter => "@gooley"})
```

Copyright (c) 2011-2013 Christopher Gooley, Preact. See LICENSE.txt for further details.
