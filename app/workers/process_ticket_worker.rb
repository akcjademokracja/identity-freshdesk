module Identity
  module Freshdesk
    class ProcessTicketWorker
      include Sidekiq::Worker

      def perform(ticket, event)
        @event = event
        @member = FindMember.new.
                    by_email(ticket['requester']['email']).
                    by_unsubscribe_link(ticket['description'])

        return if @member.nil?
      end

    end
  end
end
