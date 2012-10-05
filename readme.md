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

Here's a sample gist of what the helper could look like:
https://gist.github.com/3738364

then you can make one-line event logs:
```ruby
Neglect.log_event(@current_user, "uploaded-media")
```

Copyright (c) 2011-2012 Christopher Gooley, Less Neglect. See LICENSE.txt for further details.