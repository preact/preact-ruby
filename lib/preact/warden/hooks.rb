# after-auth hook to log the login
Warden::Manager.after_authentication do |user,auth,opts|
  Preact.log_event(user, "login")
end
Warden::Manager.before_logout do |user,auth,opts|
  Preact.log_event(user, "logout")
end