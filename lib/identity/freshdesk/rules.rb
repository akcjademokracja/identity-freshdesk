module Identity
  module Freshdesk
    class Rules
      def initialize(ticket, member, event)
        @ticket = ticket
        @member = member
        @event = event

        # new attrs for ticket to update
        @tags = []
        @type = nil
        @priority = nil
        @status = nil
        @description = nil
      end

      def rules
        Settings.freshdesk.rules
      end

      def process(rules_arg = nil)
        rules_arg ||= rules
        rules_arg.each do |r|
          if satisfied(r)
            execute(r)
          end
        end
      end

      def as_array(thing)
        if thing.is_a? Array
          thing
        else
          [thing]
        end
      end

      # criteria part
      def satisfied(conditions)
        conditions.each do |kind, criterion|
          ok = case kind.to_s
               when 'is_type' then is_type? criterion
               when 'is_new' then is_type? 'new'
               when 'is_created' then is_type? 'new'
               when 'is_updated' then is_type? 'update'
               when 'has_status' then has_status? criterion
               when 'has_tag' then has_tag? criterion
               when 'has_tags' then has_tag? criterion
               when 'done_tag' then !has_tag? criterion
               when 'found' then criterion == @member.present?
               when 'contains' then description_contains? criterion
               when 'regular_donor' then @member.present? && (criterion == @member.has_regular_donation?)
               else true
               end

          return false if !ok
        end
        true
      end

      def is_type?(type)
        as_array(type).any? { |t| @ticket['type'] == t }
      end

      def has_status?(status)
        as_array(status).any? { |s| @ticket['status'] == status_code(s) }
      end

      def is_event?(event)
        case event
        when 'new' then @event == 'freshdesk_ticket_new'
        when 'update' then @event == 'freshdesk_ticket_new'
        else false
        end
      end

      def has_tag?(tag)
        as_array(tag).any? { |t| @ticket['tags'].include? t }
      end

      def description_contains?(words)
        from_email = Settings.options.default_mailing_from_email
        # a silly heuristic to get just reply to our email
        msg = @ticket["description_text"].split("<#{from_email}>").first
        return false if msg.nil?

        as_array(words).any? { |w| msg.include?(w) }
      end

      # action part
      def execute(actions)
        actions.each do |action, args|
          case action.to_s
          when 'tag' then tag! args
          when 'set_type' then set_type! args
          when 'set_priority' then set_priority! args
          when 'set_status' then set_status! args
          when 'done_tag' then tag! args
          when 'add_to' then @member.present? && add_to!(args)
          when 'gdpr' then @member.present? && gdpr!(args)
          when 'email' then email! args
          when 'description' then @member.present? && description!(args)
          when 'tag_by' then case args
                             when 'mailing' then tag_by_mailing!
                             else false
                             end
          end
        end
      end

      def description!(template)
        @description = render template
      end

      def tag_by_mailing!
        mailings = FindMailing.by_subject @ticket['subject']
        tags = mailings.map do |m|
          m.name.split("-")[0].truncate(20, omission: "").downcase
        end
        @tags += tags.uniq
      end

      def email!(e)
        # XXX add renders
        to = e['to']
        from = Settings.options.default_mailing_from_email
        subject = render e['subject']
        body = render e['body']

        SendEmailWorker.perform_async(to, from, subject, body)
      end

      def gdpr!(op)
        case op
        when 'forget' then Ghoster.ghost_members_by_id([@member.id], reason: "FreshDesk automation forget", admin_member_id: @member.id)
        when 'optout' then @member.unsubscribe
        end
      end

      def add_to!(name)
        list = List.find_or_create_by!(name: name)
        list.add_new_member(@member)
      end

      def tag!(tag)
        @tags += as_array(tag)
      end

      def set_type!(type)
        @type = type
      end

      def set_priority!(prio)
        @priority = prio.to_i
      end

      def set_status!(status)
        status = status.downcase
        @status = status_code status
      end

      # rendering
      def render(tmpl)
        member = @member
        ticket = @ticket
        event = @event
        ticket_id = ticket['id']
        ticket_link = "https://#{Settings.freshdesk.subdomain}.freshdesk.com/helpdesk/tickets/#{ticket_id}"

        tmpl = tmpl.gsub("{{", "<%= ").gsub("}}", " %>")
        ERB.new(tmpl).result(binding)
      end

      # save to api
      def persist
        ticket_changes = ticket_changeset.select { |_k, v| !v.nil? and v != [] }
        unless ticket_changes.empty?
          UpdateTicketWorker.perform_async(@ticket['id'], ticket_changes)
        end

        requester_changes = requester_changeset.select { |_k, v| !v.nil? }
        unless requester_changes.empty?
          UpdateRequesterWorker.perform_async(@ticket['requester_id'], requester_changes)
        end
      end

      def ticket_changeset
        {
          tags: @tags,
          type: @type,
          priority: @priority,
          status: @status
        }
      end

      def requester_changeset
        { description: @description }
      end

      def status_code(status)
        case status
        when 'open' then 2
        when 'pending' then 3
        when 'resolved' then 4
        when 'closed' then 5
        else status.to_i
        end
      end
    end
  end
end
