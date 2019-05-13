module Identity
  module Freshdesk
    module API
      def self.foo
        12
      end

      def auth
        {
          username: Settings.freshdesk.api_key || ENV['FRESHDESK_API_TOKEN'],
        }
      end

      def domain
        Settings.freshdesk.subdomain + '.freshdesk.com'
      end

      def authenticated_client
        client = HTTPClient.new
        a = auth()
        d = "https://#{domain}/api/v2"
        client.set_auth(nil, a[:username], a[:password])
        client
      end

      def request(url)
        c = authenticated_client()
        r = c.get(url)

      end

      def get_ticket(ticket_id)
        url = "https://#{domain}/api/v2/tickets/#{ticket_id}?include=requester"
        request(url)
      end

      def rate_limit_hit?(response)
        # Throw an exception upon hitting the rate limit
        if response.headers["x-ratelimit-remaining"].to_i < 2 or response.response["status"] == "429"
          # reschedule it for later
          puts "Rate limit hit. Will retry after #{(response.response["retry-after"].to_i + 10) / 60} minutes."
          AortaCheckTicketWorker.perform_in(response.headers["retry-after"].to_i + 10, @ticket_id)
          return true
        elsif response.response["status"] != "200 OK"
          raise AortaCheckTicketWorker::FreshDeskError.new("Something went wrong! Status: #{response.response["status"]} ReqId: #{response.headers['x-requestid']}")
        end
        false
      end

    end
  end
end
