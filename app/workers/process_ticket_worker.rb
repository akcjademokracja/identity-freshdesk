module Identity
  module Freshdesk
    class ProcessTicketWorker
      include Sidekiq::Worker

      def perform(ticket, event)
        @event = event
        @member = FindMember.by_email(ticket['requester']['email']) or
          @member = FindMember.by_unsubscribe_link(ticket['description'])


      end

    end
  end
end
