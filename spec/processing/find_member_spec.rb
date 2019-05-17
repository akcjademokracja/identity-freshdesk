require 'spec_helper'
require 'cgi'

describe 'Finding member' do
  let (:member) { FactoryBot.create(:member) }
  let (:email) { member.email }
  subject { member }

  describe 'by email' do
    let (:member) { Identity::Freshdesk::FindMember.by_email(email) }
    it { is_expected.not_to be nil }
    it { is_expected.to have_attributes email: email }
  end

  describe 'by unsub link' do
    let (:body) {
      %Q{
<p>This is some email.</p>

<a href="#{Settings.app.inbound_url}/subscriptions/unsubscribe?email=#{CGI::escape(email)}">
Unsubscribe here!
</a>
         }
    }
    let (:member) { Identity::Freshdesk::FindMember.by_unsubscribe_link(body) }
    it { is_expected.not_to be nil }
    it { is_expected.to have_attributes email: email }
  end
end
