# frozen_string_literal: true

require_relative '../lib/obscured-heartbeat'
require_relative 'setup'
require_relative 'helpers/host_document'


describe Mongoid::Heartbeat::Tracker do
  let(:host) { FactoryBot.create(:host) }
  let(:host2) { FactoryBot.create(:host, hostname: 'host2.domain.tld') }
  let!(:template) {
    {
      distribution: {
        name: 'Ubuntu',
        release: '19.04',
        codename: 'disco',
        description: 'Ubuntu 19.04'
      },
      hostname: 'host.domain.tld',
      ip_address: '10.0.1.1',
      uptime: Time.now.to_i
    }
  }

  describe 'heartbeat' do
    context 'add heartbeat' do
      let!(:heartbeat) { host.add_heartbeat(template) }

      it { expect(heartbeat.hostname).to eq(template[:hostname]) }
      it { expect(heartbeat.proprietor).to eq(host_id: host.id) }
    end

    context 'get heartbeat' do
      let!(:heartbeat) { host.add_heartbeat(template) }
      let(:response) { host.get_heartbeat(heartbeat.id) }

      it { expect(response.id).to eq(heartbeat.id) }
      it { expect(response.hostname).to eq(heartbeat.hostname) }
    end

    context 'get heartbeats' do
      let!(:heartbeat) { host.add_heartbeat(template) }
      let!(:heartbeat2) { host.add_heartbeat(template) }
      let(:response) { host.get_heartbeats }

      it { expect(response.count).to eq(2) }
    end

    context 'find heartbeats' do
      let(:response) { host.find_heartbeats({ hostname: host.hostname }, {}) }

      before(:each) do
        host.add_heartbeat(template.merge(hostname: host.hostname))
        host.add_heartbeat(template.merge(hostname: host.hostname))
        host.add_heartbeat(template.merge(hostname: 'foo.bar.tld'))
      end

      it { expect(response.count).to eq(2) }
    end

    context 'search heartbeats' do
      before(:each) do
        10.times do
          host.add_heartbeat(template)
        end

        5.times do
          host2.add_heartbeat(template)
        end
      end

      context 'via id with limit' do
        let(:response) { host.search_heartbeats(host.id.to_s, limit: 5) }

        it { expect(response.count).to eq(5) }
      end

      context 'via hostname with limit' do
        let(:response) { host.search_heartbeats(template[:hostname], limit: 10) }

        it { expect(response.length).to eq(10) }
      end
    end

    context 'edit heartbeat' do
      let!(:heartbeat) { host.add_heartbeat(template) }

      context 'updates message for the event' do
        before(:each) do
          host.edit_heartbeat(heartbeat.id, hostname: 'host3.domain.tld')
        end

        it { expect(host.get_heartbeat(heartbeat.id).hostname).to eq('host3.domain.tld') }
      end
    end

    context 'delete heartbeat' do
      let!(:heartbeat) { host.add_heartbeat(template) }

      context 'deletes the event' do
        before(:each) do
          host.delete_heartbeat(heartbeat.id)
        end

        it { expect(host.get_heartbeat(heartbeat.id)).to be_nil }
      end
    end
  end
end