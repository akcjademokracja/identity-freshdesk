module Identity
  module Freshdesk
    class ProcessTicketWorker
      include Sidekiq::Worker

      def perform(ticket, event)
        @event = event
        (@member = FindMember.by_email(ticket['requester']['email'])) ||
          (@member = FindMember.by_unsubscribe_link(ticket['description']))

        rules = Rules.new(ticket, @member, event)

        rules.process
        rules.persist
      end
    end
  end
end
