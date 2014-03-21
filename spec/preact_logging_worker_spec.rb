require 'spec_helper'
require 'preact/sidekiq'

describe Preact::Sidekiq::PreactLoggingWorker do
  
  let(:project_code) { "abc123" }
  let(:api_secret) { "fjef3fj" }
  let(:response) { double("Response", code: 200) }

  describe "general" do

    before(:each) do
      Preact::Client.any_instance.stub(:post_request).and_return(response)
      Preact::Client.any_instance.stub(:get_request).and_return(response)

      @event_params = { 
        name: "my-event" 
      }

      @person_params = {
        uid: "123",
        email: "c@thebob.com",
        name: "Christopher Gooley"
      }

      @account_params = {
        id: "567",
        name: "Preact",
        license_mrr: 500
      }

    end

    describe "with default settings" do

      before(:each) do
        Preact.configure do |client|
          client.code = project_code
          client.secret = api_secret
        end
      end

      it "should queue the event log using sidekiq" do
        Preact::Sidekiq::PreactLoggingWorker.get_sidekiq_options["queue"].should eql(:default)

        Preact::Sidekiq::PreactLoggingWorker.should_receive(:perform_async).with({
              uid: "123",
              email: "c@thebob.com",
              name: "Christopher Gooley"
            }, {
              name: "my-event",
              klass: "actionevent"
            }
          )

        Preact.log_event(@person_params, @event_params)
      end

      it "should actually log the event" do
        Preact::Sidekiq::PreactLoggingWorker.should_receive(:perform_async)
        Preact.log_event(@person_params, @event_params)
      end


    end

    describe "with custom queue" do

      before(:each) do
        Preact.configure do |client|
          client.code = project_code
          client.secret = api_secret
          client.sidekiq_queue = :fancy_queue
        end
      end

      it "should queue the event log using sidekiq" do
        Preact::Sidekiq::PreactLoggingWorker.get_sidekiq_options["queue"].should eql(:fancy_queue)

        Preact::Sidekiq::PreactLoggingWorker.should_receive(:perform_async).with({
              uid: "123",
              email: "c@thebob.com",
              name: "Christopher Gooley"
            }, {
              name: "my-event",
              klass: "actionevent"
            }
          )

        Preact.log_event(@person_params, @event_params)
      end

    end

  end

end
