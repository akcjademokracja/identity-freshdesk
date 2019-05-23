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

    ticket_ids = []
    while scan
      tickets = list_tickets(page)

      break if tickets.empty?

      tickets.each do |t|
        if t.created_at < oldest
          scan = false
          break
        end
        ticket_ids << t["id"]
      end
      page += 1
    end
    ticket_ids.each do |tid|
      Identity::Freshdesk::FetchTicketWorker.perform_async(tid, "rescan")
    end
  end
end
