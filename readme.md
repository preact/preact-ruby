LessNeglect Ruby Client
===
Allow your Ruby app to easily submit server-side messages and events to LessNeglect.

Installation
---

In your Gemfile:

```ruby
gem 'lessneglect', :git => 'git://github.com/zmillman/lessneglect-ruby.git'
```

Configuration
---

Configure LessNeglect with your API credentials. (This should go in an initializer in Rails applications)

```ruby
LessNeglect.configure do |config|
  config.code   = 'abcdefg'           # required
  config.secret = '1234asdfasdf1234'  # required
  
  # Disable in Rails development environments
  # config.disabled = (Rails.env != "development")
  
  # Uncomment this this line to customize the data sent with your Person objects.
  # Your procedure should return a Hash of attributes
  # config.person_builder = lambda {|user| user.to_person}
end
```

Usage
---

```ruby
person = {
  :name => "Christopher Gooley",
  :email => "gooley@foliohd.com",
  :external_identifer => "gooley",
  :properties => {
    :account_level => "Pro",
    :is_paying => True,
    :created_at => 1347060566
  }
}

LessNeglect.log_event(person, 'upgraded', :price_paid => '25.00')
```

Rails 3 Usage
---
In your `User` model, you can define a `to_person` method returning a Hash. LessNeglect will detect if this method is defined and use it for API calls, e.g.

```ruby
class User < ActiveRecord::Base

  def to_person
    {
      :name => self.name,
      :email => self.email,
      :external_identifer => self.id,
      :properties => {
        :account_level => self.account_level,
        :is_paying => self.paying_customer?,
        :created_at => self.created_at.to_i
      }
    }
  end
  
end
```

Copyright (c) 2011-2012 Christopher Gooley, Less Neglect. See LICENSE.txt for further details.