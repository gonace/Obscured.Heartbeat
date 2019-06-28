# frozen_string_literal: true

require_relative 'setup'
require_relative 'helpers/host_document'
require_relative 'helpers/gateway_document'


describe Mongoid::Heartbeat::Tracker do
  let(:host) { FactoryBot.create(:host) }
  let(:gateway) { FactoryBot.create(:gateway) }
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

  describe 'write heartbeat' do
    context 'validates that that heartbeats is written to correct collection' do
      let!(:host_heartbeat) { host.add_heartbeat(template) }
      let!(:gateway_heartbeat) { gateway.add_heartbeat(template) }

      context 'for host' do
        it { expect(host_heartbeat.hostname).to eq(template[:hostname]) }
        it { expect(host_heartbeat.proprietor).to eq(host_id: host.id) }

        context 'get heartbeat' do
          let!(:heartbeat) { host.add_heartbeat(template) }
          let!(:response) { host.get_heartbeat(heartbeat.id) }

          it { expect(response.hostname).to eq(template[:hostname]) }
          it { expect(response.proprietor).to eq("host_id" => host.id) }
        end

        context 'get heartbeats' do
          let!(:response) { host.get_heartbeats }

          it { expect(response.length).to eq(1) }
        end

        context 'find heartbeats' do
          let!(:heartbeat) { host.add_heartbeat(template) }
          let!(:heartbeat) { host.add_heartbeat(template) }
          let!(:heartbeat3) { host.add_heartbeat(template) }
          let!(:response) { host.find_heartbeats({ hostname: template[:hostname] }, { }) }

          it { expect(response.length).to eq(3) }
        end

        context 'search heartbeats' do
          before(:each) do
            10.times do
              host.add_heartbeat(template)
            end
          end

          let!(:heartbeat) { host.add_heartbeat(template) }
          let!(:heartbeat2) { host.add_heartbeat(template) }
          let!(:response) { host.search_heartbeats(host.id, limit: 5) }

          it { expect(response.length).to eq(5) }
        end
      end

      context 'for gateway' do
        it { expect(gateway_heartbeat.hostname).to eq(template[:hostname]) }
        it { expect(gateway_heartbeat.proprietor).to eq(gateway_id: gateway.id) }

        context 'get heartbeat' do
          let!(:heartbeat) { gateway.add_heartbeat(template) }
          let!(:response) { gateway.get_heartbeat(heartbeat.id) }

          it { expect(response.id).to eq(heartbeat.id) }
          it { expect(response.hostname).to eq(template[:hostname]) }
          it { expect(response.proprietor).to eq("gateway_id" => gateway.id) }
        end

        context 'get heartbeats' do
          let!(:response) { gateway.get_heartbeats }

          it { expect(response.length).to eq(1) }
        end

        context 'find heartbeats' do
          let!(:heartbeat) { gateway.add_heartbeat(template) }
          let!(:heartbeat2) { gateway.add_heartbeat(template) }
          let!(:heartbeat3) { gateway.add_heartbeat(template) }
          let!(:response) { host.find_heartbeats({ hostname: template[:hostname] }, limit: 1) }

          it { expect(response.length).to eq(1) }
        end

        context 'search heartbeats' do
          before(:each) do
            10.times do
              gateway.add_heartbeat(template)
            end
          end
          let!(:response) { gateway.search_heartbeats(gateway.id, limit: 5) }

          it { expect(response.length).to eq(5) }
        end
      end
    end
  end
end