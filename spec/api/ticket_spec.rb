require 'spec_helper'

class FD
  include Identity::Freshdesk::API
end

describe 'Freshdesk API for ticket' do
  let (:ticket_id) { 15243 }
  let (:api) { FD.new }


  describe 'set type' do
    let (:update) { api.update_ticket(ticket_id, {type: "Media"}) }

    it 'succeeds' do
      VCR.use_cassette('freshdesk/ticket_set_type', record: :all) do
        expect(update).to have_key 'type'
        expect(update['type']).to eq('Media')
      end
    end
  end

  describe 'set priority' do
    let (:update) { api.update_ticket(ticket_id, {priority: 3}) }

    it 'succeeds' do
      VCR.use_cassette('freshdesk/ticket_set_priority', record: :all) do
        expect(update).to have_key "priority"
        expect(update['priority']).to eq(3)
      end
    end
  end
end
