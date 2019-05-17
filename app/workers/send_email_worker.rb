module Identity
  module Freshdesk
    class SendEmailWorker
      include Sidekiq::Worker

      def perform(to, from, subject, body)
        TransactionalMail.send_email(
          to: [to],
          from: "Freshdesk automation <#{from}>",
          subject: subject,
          body: body
        )
      end
    end
  end
end
