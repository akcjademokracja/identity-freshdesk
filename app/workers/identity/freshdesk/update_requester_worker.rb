module Identity
  module Freshdesk
    class UpdateRequesterWorker
      include Sidekiq::Worker
      include API

      def perform(requester_id, attributes)
        begin
          Sidekiq::Logging.logger.debug("Update requester #{requester_id} with #{attributes}")
          update_requester(requester_id, attributes)
        rescue API::Retry => try_again
          # retry after limit is restored
          self.schedule_in try_again.in_seconds
        end
      end
    end
  end
end
