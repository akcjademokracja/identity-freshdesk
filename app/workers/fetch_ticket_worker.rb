module Identity
  module Freshdesk
    class FetchTicketWorker
      include Sidekiq::Worker
      include API

      def perform(ticket_id, event)
        begin
          ticket = get_ticket(ticket_id)

          return if avoid_ticket? ticket

          # pass to processing
          ProcessTicketWorker.perform_async(ticket, event)

        rescue API::Retry => try_again
          # retry after limit is restored
          self.class.schedule_in try_again.in_seconds
        end
      end

      def avoid_ticket?(ticket)
        # If the subject is empty, stop processing the ticket; FreshDesk will
        # throw 400 Bad Request at you if you try updating a ticket without a
        # subject. Thanks FreshDesk!
        return true if ticket['subject'].empty?

        # Do not process non-email tickets
        return true if result['source'].to_i != 1

        # Do not process if the ticket e-mail wasn't sent to the "contact"
        # e-mail address
        if result['to_emails']
          default_email = Settings.options.default_mailing_from_email
          return result['to_emails'].none? { |a| a.include? default_email }
        end

        false
      end
    end
  end
end
