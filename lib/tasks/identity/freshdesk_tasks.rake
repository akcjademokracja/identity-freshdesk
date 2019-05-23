# desc "Explaining what the task does"
# task :identity_freshdesk do
#   # Task goes here
# end

namespace :freshdesk do
  desc "Rescan and process the last X days"
  task :rescan, [:days] => [:environment] do |_t, args|
    include Identity::Freshdesk::API
    oldest = DateTime.now - args[:days].to_i.days
    page = 1
    scan = true
    while scan
      tickets = list_tickets(page)

      break if tickets.empty?

      tickets.each do |t|
        if t.created_at < oldest
          scan = false
          break
        end
        Identity::Freshdesk::FetchTicketWorker.perform_async(t["id"], "rescan")
      end
      page += 1
    end

  end
end
