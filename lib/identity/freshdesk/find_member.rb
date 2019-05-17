# coding: utf-8

module Identity
  module Freshdesk
    class FindMember
      def self.by_email(member_email)
        member = Member.find_by email: member_email

        # Try google.mail → gmail.com
        unless member && member_email.include?("@googlemail.com")
          member_email.gsub!("@googlemail.com", "@gmail.com")
          member = Member.find_by email: member_email
        end

        member
      end

      def self.by_unsubscribe_link(body)
        unsub_email_regex = Regexp.new("#{Settings.app.inbound_url}\/subscriptions\/unsubscribe[?]email=(.+?)[&\"]")

        if (unsub_email = body.match(unsub_email_regex))
          unsub_email = unsub_email[1]
          unsub_email.gsub!("%40", "@") if unsub_email.include?("%40")
          Member.find_by email: unsub_email
        end
      end
    end
  end
end
