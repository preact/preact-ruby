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
        user = Preact.configuration.get_current_user(self) # handle nil
        account ||= Preact.configuration.get_current_account(self) # handle nil

        Preact.log_event(user, event, account)

        # make a note that we've logged an event on this controller
        @preact_logged_event = event
      end

      def inject_javascript
        if after_head_index = find_head_index(response.body)
          script_lnq = lnq_definition_script
          response.body = response.body.insert(after_head_index, script_lnq)
          if body_end = response.body.index("</body")
            script = build_script
            response.body = response.body.insert(body_end, script)
          end
        end
      end

      # attach the after_filter to all controllers if we've enabled autologging
      if Preact.configuration.autolog_enabled?
        ActiveSupport.on_load(:action_controller) do
          after_filter :preact_autolog_controller_action
        end
      end

      ActiveSupport.on_load(:action_controller) do
        after_filter :inject_javascript
      end


      protected

        def build_script
          script = <<-SCRIPT
<script>
  var _lnq = _lnq || [];
  _lnq.push(['_setCode', '#{Preact.configuration.code.to_s}']);
  _lnq.push(['_setPersonData', #{Preact.configuration.convert_to_person(Preact.configuration.get_current_user(self)).to_json}]);
  _lnq.push(['_setAccount', #{Preact.configuration.convert_to_account(Preact.configuration.get_current_account(self)).to_json}]);

  (function() {
    var ln = document.createElement('script'); 
    ln.type = 'text/javascript'; ln.async = true;
    ln.src = 'https://d2bbvl6dq48fa6.cloudfront.net/js/ln-2.4.min.js';
    var s = document.getElementsByTagName('script')[0]; 
    s.parentNode.insertBefore(ln, s);
  })();
</script>
SCRIPT
        end

        def lnq_definition_script
          script = <<-SCRIPT
\n
<script>
  var _lnq = _lnq || [];
</script>
SCRIPT
        end

        def find_head_index(response_body)
          if head_start = response_body.index("<head")
            if head_tag = response_body.match(/<head.*>/)[0]
              return head_start + head_tag.length
            end
          end
          false
        end

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