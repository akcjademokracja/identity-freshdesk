module Identity
  module Freshdesk
    class UpdateTicketWorker
      include Sidekiq::Worker
      include API

      def perform(ticket_id, attributes)
        begin
          update_ticket(ticket_id, attributes)
        rescue API::Retry => try_again
          # retry after limit is restored
          self.class.schedule_in try_again.in_seconds
        end
      end
    end
  end
end
