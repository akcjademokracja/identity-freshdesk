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

        process
      end

      def rules
        Settings.freshdesk.rules
      end

      def process
        rules.each do |r|
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
          ok = case kind
               when 'is_type' then is_type? criterion
               when 'is_new' then is_type? 'new'
               when 'is_created' then is_type? 'new'
               when 'is_updated' then is_type? 'update'
               when 'has_tag' then has_tag? criterion
               when 'has_tags' then has_tag? criterion
               when 'done_tag' then not has_tag? criterion
               else true
               end

          return false if not ok
        end
        true
      end

      def is_type?(type)
        as_array(type).any { |t| ticket['type'] == t}
      end

      def is_event?(event)
        case event
        when 'new' then @event == 'freshdesk_ticket_new'
        when 'update' then @event == 'freshdesk_ticket_new'
        else false
        end
      end

      def has_tag?(tag)
        as_array(tag).any { |t| @ticket['tags'].include? t }
      end

      # action part
      def execute(actions)
        actions.each do |action, args|
          case action
          when 'tag' then tag! args
          when 'set_type' then set_type! args
          when 'set_priority' then set_priority! args
          when 'set_status' then set_status! args
          when 'done_tag' then tag! args
          end
        end
      end

      def tag!(tag)
        @tags << as_array(tag)
      end

      def set_type!(type)
        @type = type
      end

      def set_priority!(prio)
        @priority = prio.to_i
      end

      def set_status!(status)
        status = status.downcase
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
