# coding: utf-8
module Identity
  module Freshdesk
    class FindMember
      attr_accessor :member
      def initialize
        @member = nil
      end

      def by_email(member_email)
        return self if @member

        @member = Member.find_by email: member_email

        # Try google.mail → gmail.com
        unless @member and member_email.include? "@googlemail.com"
          member_email.gsub!("@googlemail.com", "@gmail.com")
          @member = Member.find_by email: member_email
        end

        self
      end

      def by_unsubscribe_link(body)
        return self if @member

        unsub_email_regex = Regexp.new("#{Settings.app.inbound_url}\/subscriptions\/unsubscribe[?]email=(.+?)[&\"]")

        if unsub_email = body.match(unsub_email_regex)
          unsub_email = unsub_email[1]
          unsub_email.gsub!("%40", "@") if unsub_email.include?("%40")
          @member = Member.find_by email: unsub_email
        end

        self
      end
    end
  end
end
