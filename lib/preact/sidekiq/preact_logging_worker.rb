require 'sidekiq'

module Preact::Sidekiq
  class PreactLoggingWorker
    include ::Sidekiq::Worker

    def perform(person, event=nil)
      client = Preact::Client.new
      if event
        client.create_event(person, event)
      else
        client.update_person(person)
      end
    end

  end
end