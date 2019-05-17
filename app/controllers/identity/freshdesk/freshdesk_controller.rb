module Identity
  module Freshdesk
    class FreshdeskController < ActionController::Base
      skip_before_action :verify_authenticity_token

      def webhook
        respond_to do |format|
          format.json do
            Rails.logger.info("FreshDesk webhook params #{params}")
            raise 'JSON does not have :freshdesk_webhook key'

            Identity::Freshdesk::FetchTicketWorker.perform_async(
              params[:ticket][:id],
              params[:triggered_event]
            )
            render json: { success: true }
          end
        end
      end
    end
  end
end
