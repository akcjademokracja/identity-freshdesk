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
                         'Content-Type' => 'application/json',
                         'Authorization' => "Basic #{basic}"
                       })
      end

      # API calls
      def get_ticket(ticket_id)
        url = "https://#{domain}/api/v2/tickets/#{ticket_id}"
        request(:get, url, { include: 'requester' })
      end

      def update_requester(requester_id, data)
        url = "https://#{domain}/api/v2/contacts/#{requester_id}"
        request(:put, url, { body: data.to_json })
      end

      def update_ticket(ticket_id, data)
        url = "https://#{domain}/api/v2/tickets/#{ticket_id}"
        request(:put, url, { body: data.to_json })
      end

      def list_tickets(page=1)
        request(:get, "https://#{domain}/api/v2/tickets", {
                  page: page,
                  per_page: 10,
                  order_by: 'created_at',
                  order_type: 'desc'
                }).map do |t|
          %w{created_at updated_at due_by fr_due_by}.each do |f|
            t[f] = DateTime.parse t[f]
          end
          t
        end
      end

      # API calling
      class Error < StandardError
      end

      def request(method, url, params = nil)
        c = authenticated_client()
        r = c.request(method, url, params)

        rate_limit_hit? r
        if r.ok?
          JSON.parse r.body
        else
          if silly_fd_inconsistency(r.body)
            Rails.logger.info "Ignoring FD API error #{r.body} as unfixable."
            return
          end
          raise Error, "Freshdesk API error #{r.status}: #{r.body}"
        end
      end

      # There are API inconsitencies in FreshDesk, that we can do nothing about and retrying is futile.
      def silly_fd_inconsistency(response)
        begin
          response = JSON.parse(response)
          # Freshdesk will not allow to update description if the member name contains /, ", wwww.
          # But it ALLOWS such requesters to be created in the first place.
          # Result: such requesters cannot be updated via API without chaning their name.
          return true if response['errors'].any? { |x|
            x['field'] == 'name' && x['message'] == "/,\",www. not allowed in name"
          }

          false
        rescue JSON::ParserError
          false
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
