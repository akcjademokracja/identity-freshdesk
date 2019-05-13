require 'spec_helper'

class FD
  include Identity::Freshdesk::API
end

describe 'Freshdesk api auth' do
  let (:ticket_id) { 53606 }
  let (:api) { FD.new }

  describe 'settings' do
    it 'has X as password' do
      expect(api.auth[:password]).to eq 'X'
    end

    it 'has non blank api key' do
      expect(api.auth[:username]).not_to be_blank
    end
  end

  describe 'get ticket' do
    let(:ticket) { api.get_ticket(ticket_id) }
    it 'fetches a ticket with requester data' do
      VCR.use_cassette('freshdesk/tickets_53606', record: :all) do
        expect(ticket['id']).to eq ticket_id
        expect(ticket['requester']['email']).to eq 'mfurmanowski@op.pl'
      end
    end
  end
end
