# coding: utf-8
require 'spec_helper'

describe 'rule' do
  let (:ticket) {
    {"cc_emails"=>[],
     "fwd_emails"=>[],
     "reply_cc_emails"=>[],
     "ticket_cc_emails"=>[],
     "fr_escalated"=>true,
     "spam"=>false,
     "email_config_id"=>19000019709,
     "group_id"=>nil,
     "priority"=>3,
     "requester_id"=>19000297879,
     "responder_id"=>nil,
     "source"=>1,
     "company_id"=>nil,
     "status"=>5,
     "subject"=>"AORTA TEST",
     "association_type"=>nil,
     "to_emails"=>["kontakt@akcjademokracja.pl"],
     "product_id"=>nil,
     "id"=>15243,
     "type"=>"Media",
     "due_by"=>"2017-09-01T16:13:18Z",
     "fr_due_by"=>"2017-08-28T16:13:18Z",
     "is_escalated"=>true,
     "description"=>"<div>fdsfds<br><br>\n</div>",
     "description_text"=>"fdsfds\n\n",
     "custom_fields"=>{"follow_up"=>nil},
     "created_at"=>"2017-08-25T16:13:18Z",
     "updated_at"=>"2019-05-14T14:08:20Z",
     "tags"=>["money", "airpolution"],
     "attachments"=>[],
     "source_additional_info"=>nil,
     "requester"=>{"id"=>19000297879, "name"=>"Marcin Tester", "email"=>"marcin@blah.pl", "mobile"=>"", "phone"=>""}}
  }

  let (:member) { FactoryBot.create :member, email: ticket['requester']['email']}

  let (:rules) { Identity::Freshdesk::Rules.new ticket, member, 'freshdesk_ticket_new'}

  describe "is satisfied by" do
    subject { rules.satisfied(conditions) }
    describe "type" do
      let (:conditions) {
        {is_type: 'Media'}
      }

      it { is_expected.to be true }
    end

    describe "many types" do
      let (:conditions) {
        {is_type: ['Foo', 'Bar', 'Media']}
      }

      it { is_expected.to be true }
    end

    describe "tag" do
      let (:conditions) { {has_tag: 'money'} }
      it { is_expected.to be true }
    end

    describe 'few tags' do
      let (:conditions) { {has_tag: ['baloon', 'money']} }
      it { is_expected.to be true }
    end

    describe 'present done tag' do
      let (:conditions) { {done_tag: 'money'} }
      # 'money' tag means it was already done, should not match
      it { is_expected.to be false }
    end

    describe "wrong type and existing tag" do
      let (:conditions) { {is_type: 'Food', has_tag: 'money'} }
      it { is_expected.to be false }
    end

    describe 'member is found' do
      let (:conditions) { {found: true} }
      it { is_expected.to be true }
    end
  end

  describe "execution of actions changing ticket's" do
    before (:each) { rules.execute(actions) }
    subject { rules.ticket_changeset }

    describe "type" do
      let (:actions) {{set_type: 'Pizza'}}
      it { is_expected.to include(type: 'Pizza') }
    end

    describe 'tag' do
      let (:actions) {{tag: 'fast-food'}}
      it { is_expected.to include(tags: ['fast-food']) }
    end

    describe 'status' do
      let (:actions) {{set_status: 'pending'}}
      it { is_expected.to include(status: 3) }
    end

    describe 'priority' do
      let (:actions) {{set_priority: 4}}
      it { is_expected.to include(priority: 4) }
    end
  end

  describe 'renderring' do
    subject { rules.render(template) }
    describe 'of ticket_id' do
      let (:template) { 'ticket id is {{ticket_id}}' }
      it { is_expected.to eq 'ticket id is 15243'}
    end

    describe 'of member email' do
      let (:template) { 'unsub {{member.email}}' }
      it { is_expected.to eq "unsub #{member.email}"}
    end

    describe 'of ticket link' do
      let (:template) { '<a href="{{ticket_link}}">ticket</a>' }
      it { is_expected.to eq "<a href=\"https://akcjademokracja.freshdesk.com/helpdesk/tickets/15243\">ticket</a>"}
    end

    describe 'of ticket tags' do
      let (:template) { 'tags: {{ticket["tags"].join(", ")}}' }
      it { is_expected.to eq "tags: money, airpolution"}
    end

  end
end
