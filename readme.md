LessNeglect Ruby Client
===
Allow your Ruby app to easily submit server-side messages and events to LessNeglect.

Installation
---

In your Gemfile:

```ruby
gem 'lessneglect', :git => 'git://github.com/lessneglect/lessneglect-ruby.git'
```

Configuration
---

Configure LessNeglect with your API credentials. (This should go in an initializer file named `/config/initializers/lessneglect.rb` in Rails applications)

```ruby
LessNeglect.configure do |config|
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
  :external_identifer => "gooley",
  :properties => {
    :account_level => "Pro",
    :is_paying => true,
    :created_at => 1347060566
  }
}

#common event examples:
LessNeglect.log_event(person, 'logged-in')
LessNeglect.log_event(person, 'upgraded', :price_paid => '25.00')
LessNeglect.log_event(person, "uploaded:file", :note => "awesome_resume.pdf")
LessNeglect.log_event(person, "uploaded:image", :note => "cool_image_12.jpg")
LessNeglect.log_event(person, 'purchased-item', {:note => "black shoes", :extras => {:revenue => 25.00, :size => "mens 13"})
```

ActiveRecord Integration
---
In your `User` model, you can define a `to_person` method returning a Hash. LessNeglect will detect and use this method on users passed to its logging events.

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

```ruby
LessNeglect.message(User.find(1), "I'm having trouble getting my old answers back. Can you help me?")

LessNeglect.log_event(User.find(1), 'restored_answer_data')
LessNeglect.log_event(User.find(1), 'updated-profile', :extras => {:twitter => "@gooley"})
```

Copyright (c) 2011-2012 Christopher Gooley, Less Neglect. See LICENSE.txt for further details.
