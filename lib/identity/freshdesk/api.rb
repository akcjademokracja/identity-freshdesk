module Identity
  module Freshdesk
    module API
      def auth
        {
          username: Settings.freshdesk.api_key || ENV['FRESHDESK_API_TOKEN'],
          password: 'X'
        }
      end

      def domain
        Settings.freshdesk.subdomain + '.freshdesk.com'
      end

      def authenticated_client
        a = auth
        # Somehow HTTPClient.set_auth does not work.
        basic = Base64.strict_encode64(a[:username] + ':' + a[:password])
        HTTPClient.new(default_header: {
                         'Authorization' => "Basic #{basic}"
                       })
      end

      # API calls
      def get_ticket(ticket_id)
        url = "https://#{domain}/api/v2/tickets/#{ticket_id}?include=requester"
        request(url)
      end

      # API calling
      class Error < StandardError
      end

      def request(url)
        c = authenticated_client()
        r = c.get(url)

        rate_limit_hit? r
        if r.ok?
          JSON.parse r.body
        else
          raise Error, "Freshdesk API error #{r.status}: #{r.body}"
        end

      end


      # Rate limiting of API calls
      class Retry < StandardError
        attr_reader :in_seconds
        def initialize(in_seconds)
          super "Freshdesk rate limit hit. Retry in #{in_seconds}"
          @in_seconds = in_seconds
        end
      end

      def rate_limit_hit?(response)
        # Throw an exception upon hitting the rate limit
        if response.status == 429
          # reschedule it for later
          schedule_in = response.headers['retry-after'].to_i + 10

          raise Retry.new(schedule_in)
        end
      end
    end
  end
end
