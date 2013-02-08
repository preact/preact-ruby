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

Copyright (c) 2011-2012 Christopher Gooley, Less Neglect. See LICENSE.txt for further details.