Preact Logging API Ruby Client
===
Allow your Ruby app to easily submit server-side messages and events to Preact.

Installation
---

In your Gemfile:

```ruby
gem 'preact', "~> 1.0"
```

Then do a `bundle install` to get the gem.

Configuration
---

In version 0.8.1 we added a rails generator to make it really easy to add the initializer and get you up and running.

First, obtain your Preact Project Code and API Secret from the [API settings page](https://secure.preact.io/settings/api). Then, in your application directory, run the generator:

```bash
rails g preact your-code-1234 api-secret-xyzw
```

That will generate a preact.rb initializer that looks something like this:

```ruby
Preact.configure do |config|
  config.code   = 'your-code-1234'           # required
  config.secret = 'api-secret-xyzw'  # required
  
  config.autolog = true
  config.autolog_ignored_actions = ["sessions#create"]

  # Disable in Rails development environments
  # config.disabled = Rails.env.development?
end
```

Now when you launch your app and do something as an authenticated user, you should see the activity in Preact.

Autolog
---

New in version 0.8.1 is the ability to automatically log all controller-based actions that your authenticated users are performing.

In many cases, you won't need to do anything other than put the gem in your Gemfile, bundle, and run the generator.

This works by creating an method on the ActiveController::Base class and setting it as an after_filter for all controllers. We assume that you're using Devise/Warden, because everyone does, and can directly access that to identify who the current_user is. With Autolog enabled, what you will see is rails routes-style events in Preact for each user.

We turn Autolog on by default when you use the generator to build the preact.rb initializer, but if you're upgrading from an existing preact-ruby install you will need to manually update your config.

You can configure controllers and routes to ignore by adding them in the initializer as well. If you want to ignore a specific action, you can include it like so:

```ruby
config.autolog_ignored_actions = [
    "documents#new", # ignores the new action on the documents_controller
    "people#new", # ignores the new action on the people_controller
    "secret_pages#*" # ignores ALL actions on the secret_pages_controller
  ]
```

Rails Controller Helper
---

Since version 0.8.1, we include a helper method on the base controller called `preact_log` to make it convenient for you to log events directly.

The helper is aware of the current_user and so only requires you to pass the event information as things occur. So for instance, you may log a simple event from one of yoru controllers like so:

```ruby
class DocumentsController < ApplicationController
  def show
    # YOUR CODE STUFF HERE

    preact_log("did-something-cool")
  end
  
  def search
    # YOUR CODE STUFF HERE
    
    preact_log({
      name: "searched-documents",
      note: @search_term,
      extras: {
        term: @search_term,
        result_count: @results.count
      }
    })
  end
end
```

#### B2B Event Logging

If you are logging Accounts in a B2B context, you may find it useful to override the preact_log helper at the ApplicationController level.

Typically, you'll have a variable or method which provides the current context that the `@current_user` is acting under. For us, it's called `@current_project`.

Adding this override will make sure that everywhere you call preact_log, it will automatically include the account context when logging events.

```ruby
class ApplicationController

  def preact_log(event, account=nil)
    account ||= @current_project
    super(event, account)
  end

end
```

Note: If you make this change in your ApplicationControler, make sure you add it to any other base controllers you have that don't inherit from ApplicationController (e.g. your API base controller, etc)

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

#### B2B Account mapping method

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
If you are using Warden, Preact will automatically log your login/logout events. 
If when Preact loads, it notices that a ::Warden class is defined, it will require the preact/warden module which adds the appropriate hooks into Warden.

Background Sending
___
By default, Preact uses [SuckerPunch](https://github.com/brandonhilkert/sucker_punch) to make sure nothing gets blocked.

License
--
Copyright (c) 2011-2013 Christopher Gooley, Preact / Less Neglect, Inc. See LICENSE.txt for further details.

Thanks to [Zach Millman](https://github.com/zmillman) for many contributions.
