require 'spec_helper'

class FD
  include Identity::Freshdesk::API
end

describe 'Freshdesk API for requester' do
  let (:requester_id) { 19000297879 }
  let (:api) { FD.new }

  describe 'set description' do
    let (:desc) { "rspec test ok" }
    let (:update) { api.update_requester(requester_id, { description: desc }) }

    it 'succeeds' do
      VCR.use_cassette('freshdesk/requester_update_description', record: :all) do
        expect(update).to have_key 'description'
        expect(update!['description']).to eq(desc)
      end
    end
  end
end
