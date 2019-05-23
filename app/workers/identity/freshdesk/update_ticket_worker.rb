module Identity
  module Freshdesk
    class UpdateTicketWorker
      include Sidekiq::Worker
      include API

      def perform(ticket_id, attributes)
        begin
          Sidekiq::Logging.logger.debug("Update ticket #{ticket_id} with #{attributes}")
          update_ticket(ticket_id, attributes)
        rescue API::Retry => try_again
          # retry after limit is restored
          self.class.perform_in try_again.in_seconds, ticket_id, attributes
        end
      end
    end
  end
end
