require 'sucker_punch'

module Preact
  class BackgroundLogger
    include SuckerPunch::Job

    def perform(psn, evt)
      begin
        ::Preact.client.create_event(psn, evt)
      rescue RestClient::ResourceNotFound => ex
        puts "404 error"
      rescue SocketError => ex
        puts "socket error: #{ex.message}"
      rescue => ex
        raise ex
      end
    end
  end
end