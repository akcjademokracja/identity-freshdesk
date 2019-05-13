module Identity
  class FreshdeskController < ActionController::Base
    skip_before_action :verify_authenticity_token

    def webhook
      respond_to do |format|
        format.json do
          puts params[:ticket]
          puts params[:triggered_event]

          Freshdesk::Ticket
          render json: {success: true}
        end
      end
    end
  end
end
