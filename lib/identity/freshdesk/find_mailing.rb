# coding: utf-8

module Identity
  module Freshdesk
    class FindMailing
      def self.by_subject(subject)
        unless subject.scan(/^(odp|sv|re): (.+)/i).empty?
          subject.gsub!(/^(odp|sv|re): /i, '')
          return mailings_by_subject subject
        else
          return Mailings::Mailing.none
        end
      end

      def self.mailings_by_subject(subject)
        # By subject test variant used
        # An array of IDs matching the criteria, ex. [101, 102] or an empty array if nothing found
        mailing_ids = Mailings::Mailing.joins(:test_cases)
                             .where("mailing_test_cases.template LIKE ?", "%#{subject}%")
                             .select('DISTINCT mailings.id').pluck(:id)

        Mailings::Mailing.where(id: mailing_ids).or(Mailings::Mailing.where(subject: subject))
      end
    end
  end
end
