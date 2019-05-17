module Identity
  module Freshdesk
    class FreshdeskController < ActionController::Base
      skip_before_action :verify_authenticity_token

      def webhook
        respond_to do |format|
          format.json do
            Rails.logger.info("FreshDesk webhook params #{params}")

            unless params.has_key? :ticket and
                  params.has_key? :triggered_event and
                  params[:ticket].has_key? :id
              raise "JSON does not have needed keys; params=#{params}"
            end

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
