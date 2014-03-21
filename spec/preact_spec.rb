require 'spec_helper'

describe Preact do
  
  let(:project_code) { "abc123" }
  let(:api_secret) { "fjef3fj" }
  let(:response) { double("Response", code: 200) }

  describe "general" do

    before(:each) do

      Preact::Client.any_instance.stub(:post_request).and_return(response)
      Preact::Client.any_instance.stub(:get_request).and_return(response)

      Preact.configure do |client|
        client.code = project_code
        client.secret = api_secret
        client.logging_mode = :background
      end

    end

    describe "configuration" do

      it "should configure the client with code/api" do
        Preact.configuration.code.should eql(project_code)
        Preact.configuration.secret.should eql(api_secret)
      end

      it "should generate the right url" do
        Preact.configuration.base_uri.should eql("https://#{project_code}:#{api_secret}@api.preact.io/api/v2")
      end

    end

    describe "preparing data" do

      describe "account hash" do

        before(:each) do 
          @data = {
            id: "1234",
            name: "Preact",
            license_mrr: 500
          }
        end

        it "should convert id to external_identifier" do
          prepped = Preact.configuration.prepare_account_hash(@data)
          prepped.count.should eql(3)

          prepped[:external_identifier].should eql("1234")
          prepped[:name].should eql("Preact")
          prepped[:license_mrr].should eql(500)
        end

      end

      describe "person hash" do

        it "should convert external_identifier to uid" do
          prepped = Preact.configuration.prepare_person_hash({ external_identifier: "1234", email: "bob@bob.com" })

          prepped[:uid].should eql("1234")
          prepped.keys.count.should eql(2)
        end

        it "when including uid and external_identifier, stick with the uid and drop external_identifier" do
          prepped = Preact.configuration.prepare_person_hash({ uid: "4321", external_identifier: "1234", email: "bob@bob.com" })

          prepped[:uid].should eql("4321")
          prepped.key?(:external_identifier).should be_false
          prepped.keys.count.should eql(2)
        end

        it "should convert created_at to unix timestamp if possible" do
          d = Time.now
          prepped = Preact.configuration.prepare_person_hash({ created_at: d, email: "bob@bob.com" })

          prepped[:created_at].should be_an(Integer)
          prepped[:created_at].should eql(d.to_i)
        end

      end


    end

    describe "logging a normal event" do

      before(:each) do
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

      it "should log the event" do
        Preact::Client.any_instance.should_receive(:post_request).with("/events", {
            person: {
              uid: "123",
              email: "c@thebob.com",
              name: "Christopher Gooley"
              },
            event: {
              name: "my-event",
              source: Preact.configuration.user_agent,
              klass: "actionevent"
            }
          })

        Preact.log_event(@person_params, @event_params)
      end

      it "should log the event with account info" do
        Preact::Client.any_instance.should_receive(:post_request).with("/events", {
            person: {
              uid: "123",
              email: "c@thebob.com",
              name: "Christopher Gooley"
              },
            event: {
              name: "my-event",
              source: Preact.configuration.user_agent,
              klass: "actionevent",
              account: {
                external_identifier: "567",
                name: "Preact",
                license_mrr: 500
              }
            }
          })

        Preact.log_event(@person_params, @event_params, @account_params)
      end

    end

    describe "updating an account" do

      it "should convert account_id to external_identifier" do
        Preact::Client.any_instance.should_receive(:post_request).with("/accounts", {
            account: {
              external_identifier: "123",
              name: "Test Co."
            }
          })

        Preact.update_account({ id: "123", name: "Test Co." })
      end

    end

    describe "updating an person" do

      it "should send the correct data params" do
        Preact::Client.any_instance.should_receive(:post_request).with("/people", {
            person: {
              uid: "123",
              name: "Christopher Gooley",
              email: "c@thebob.com"
            }
          })

        Preact.update_person({ uid: "123", name: "Christopher Gooley", email: "c@thebob.com" })
      end

      it "should convert the created_date the correct data params" do
        d = Time.now

        Preact::Client.any_instance.should_receive(:post_request).with("/people", {
            person: {
              uid: "123",
              name: "Christopher Gooley",
              email: "c@thebob.com",
              created_at: d.to_i
            }
          })

        Preact.update_person({ uid: "123", name: "Christopher Gooley", email: "c@thebob.com", created_at: d })
      end

    end

  end

  describe "connection timeouts" do

    before(:each) do

      Preact.configure do |client|
        client.code = project_code
        client.secret = api_secret
        client.host = "10.255.255.1"
        client.logging_mode = :background
        client.request_timeout = 2
      end

    end

    it "should timeout quickly to a bad host" do
    
      expect{ Preact.update_account({ external_identifier: "123", name: "Test Co." }) }.to raise_exception(RestClient::RequestTimeout)

    end

  end

end
