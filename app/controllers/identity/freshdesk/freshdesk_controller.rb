module Identity
  module Freshdesk
    class FreshdeskController < ActionController::Base
      skip_before_action :verify_authenticity_token

      def webhook
        respond_to do |format|
          format.json do
            Rails.logger.info("FreshDesk webhook JSON #{params}")
            data = params[:freshdesk_webhook]

            unless data.has_key? "ticket_id" and
                  data.has_key? "triggered_event"
              raise "JSON does not have needed keys; data=#{data}"
            end

            Identity::Freshdesk::FetchTicketWorker.perform_async(
              data["ticket_id"],
              data["triggered_event"]
            )
            render json: { success: true }
          end
        end
      end
    end
  end
end
