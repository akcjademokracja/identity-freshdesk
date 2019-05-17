module Identity
  class FreshdeskController < ActionController::Base
    skip_before_action :verify_authenticity_token

    def webhook
      respond_to do |format|
        format.json do
          data = params[:freshdesk_webhook]

          Freshdesk::FetchTicketWorker.perform_async(
            data[:ticket][:id],
            data[:triggered_event]
          )
          render json: {success: true}
        end
      end
    end
  end
end
