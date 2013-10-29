module Preact
  module Controllers
    module Helpers

      def preact_autolog_controller_action

        # only track logged-in users
        return true unless current_user

        # don't autolog if we logged something already on this controller execution
        # this allows you to add better preact logging in your controller and not get duplicate logging
        return true if defined?(@preact_logged_event)
        
        controller = params[:controller]
        action = params[:action]

        return true unless controller && action

        return true unless Preact.configuration.autolog_should_log?(controller, action)

        event_name = "#{controller}##{action}"

        note = self.guess_target_item_name(controller)

        event = {
          :name => event_name,
          :target_id => params[:id],
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
      rescue => ex
        Preact.logger.warn "[Preact] Autolog failed: #{ex.message}"
        true # always returns strue no matter what...
      end

      # helper method on the controller to make logging events easy
      def preact_log(event, account=nil)
        if account
          Preact.log_event(current_user, event, account)
        else
          Preact.log_event(current_user, event)
        end

        # make a note that we've logged an event on this controller
        @preact_logged_event = event
      end

      # attach the after_filter to all controllers if we've enabled autologging
      if Preact.configuration.autolog_enabled?
        ActiveSupport.on_load(:action_controller) do
          after_filter :preact_autolog_controller_action
        end
      end


      protected

        def guess_target_item_name(controller)
          # get a little too clever and try to see if we've loaded an item
          guessed_target_variable = controller.split("/").last.singularize rescue nil
          if guessed_target_variable
            if guessed_target_item = self.instance_variable_get("@#{guessed_target_variable}")
              return guessed_target_item.name if guessed_target_item.respond_to?(:name)
              return guessed_target_item.title if guessed_target_item.respond_to?(:title)
            end
          end
          nil
        end

    end
  end
end

class ActionController::Base
  include Preact::Controllers::Helpers
end