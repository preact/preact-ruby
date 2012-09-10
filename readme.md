LessNeglect Ruby Client
===
Allow your Ruby app to easily submit server-side messages and events to LessNeglect.

Installation
---

In your Gemfile:

```ruby
gem 'lessneglect'
```

Usage
---

```ruby
person = LessNeglectApi::Person.new({
    :name => "Christopher Gooley",
    :email => "gooley@foliohd.com",
    :external_identifer => "gooley",
    :properties => {
      :account_level => "Pro",
      :is_paying => True,
      :created_at => 1347060566
    }
  })

event = LessNeglectApi::ActionEvent.new({
    :name => "upgraded"
  }.merge(extras))

api = LessNeglectApi::Client.new({
    :code => "abcdefg",
    :secret => "1234asdfasdf1234"
  })

api.create_action_event(person, event)
```

Sample Helper Class
---

We suggest you create a simple helper class such as /lib/neglect.rb to convert your User model into a LessNeglect Person and submit the event.

```ruby
class Neglect
  
  def self.api
    @@api ||= LessNeglectApi::Client.new({
        :code => "asdfasdf",
        :secret => "1234asdfasdf1234"
      })
  end

  def self.log_event(user, event_name, extras = {})
    return if user.nil? || user[:impersonating]
    return if Rails.env == "development"
    
    begin
      person = LessNeglectApi::Person.new({
          :name => user.name,
          :email => user.email,
          :external_identifer => user.id,
          :properties => {
            :account_level => user.account_level,
            :is_paying => user.paying?,
            :created_at => user.created_at.to_i
          }
        })

      event = LessNeglectApi::ActionEvent.new({
          :name => event_name
        }.merge(extras))

      api.create_action_event(person, event)
    rescue
      puts "error logging to LN"
    end
  end

  def self.update_person(user)
    return if Rails.env == "development"
    
    begin
      person = LessNeglectApi::Person.new({
          :name => user.name,
          :email => user.email,
          :external_identifer => user.id,
          :properties => {
            :account_level => user.account_level,
            :is_paying => user.paying?,
            :created_at => user.created_at.to_i
          }
        })

      api.update_person(person)
    rescue
      puts "error logging to LN"
    end
  end

end
```

Helper Usage
--
```ruby
Neglect.log_event(@current_user, "uploaded-media")
```

Copyright (c) 2011-2012 Christopher Gooley, Less Neglect. See LICENSE.txt for further details.