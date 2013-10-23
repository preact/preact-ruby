module Preact
  module Controllers
    module Helpers
      extend ActiveSupport::Concern

      def preact_autolog_controller_action
        # only track logged-in users
        return true unless current_user
        
        controller = params[:controller]
        action = params[:action]
        target_id = params[:id]
        note = nil

        return true unless controller && action

        return true unless Preact.configuration.autolog_should_log?(controller, action)

        event_name = "#{controller}##{action}"

        if response.status == 404
          note = "NOT FOUND"
        elsif response.status == 500
          event_name = "!#{event_name}--error"
        end

        event = {
          :name => event_name,
          :target_id => target_id,
          :medium => "autolog-rails-v1.0",
          :note => note,
          :extras => {
            :_ip => request.remote_ip,
            :_url => request.url,
            :_ua => request.env['HTTP_USER_AGENT']
          }
        }

        preact_log(event)

        true
      end

      # helper method on the controller to make logging events easy
      def preact_log(event, account=nil)
        if account
          Preact.log_event(current_user, event, account)
        else
          Preact.log_event(current_user, event)
        end
      end

      # attach the after_filter to all controllers if we've enabled autologging
      if Preact.configuration.autolog_enabled?
        ActiveSupport.on_load(:action_controller) do
          after_filter :preact_autolog_controller_action
        end
      end

    end
  end
end

class ActionController::Base
  include Preact::Controllers::Helpers
end