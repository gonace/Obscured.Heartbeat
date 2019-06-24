# frozen_string_literal: true

require_relative '../lib/obscured-heartbeat'
require_relative 'setup'
require_relative 'helpers/host_document'
require_relative 'helpers/gateway_document'


describe Mongoid::Heartbeat::Tracker do
  let!(:message) { 'Praesent a massa dui. Etiam eget purus consequat, mollis erat et, rhoncus tortor.' }
  let(:host) { FactoryBot.create(:host) }
  let(:gateway) { FactoryBot.create(:gateway) }

  describe 'write heartbeat' do
    context 'validates that that heartbeats is written to correct collection' do
      let!(:host_heartbeat) { host.add_heartbeat(type: :comment, message: message, producer: host.id) }
      let!(:gateway_heartbeat) { gateway.add_heartbeat(type: :change, message: message, producer: gateway.id) }

      context 'for host' do
        it { expect(host_heartbeat.type).to eq(:comment) }
        it { expect(host_heartbeat.message).to eq(message) }
        it { expect(host_heartbeat.proprietor).to eq(host_id: host.id) }

        context 'get heartbeat' do
          let!(:heartbeat) { host.add_heartbeat(type: :comment, message: message, producer: host.id) }
          let!(:response) { host.get_heartbeat(heartbeat.id) }

          it { expect(response.id).to eq(heartbeat.id) }
          it { expect(response.type).to eq(heartbeat.type) }
          it { expect(response.message).to eq(heartbeat.message) }
        end

        context 'get heartbeats' do
          let!(:response) { host.get_heartbeats }

          it { expect(response.length).to eq(1) }
        end

        context 'find heartbeats' do
          let!(:heartbeat) { host.add_heartbeat(type: :comment, message: message, producer: host.id) }
          let!(:heartbeat) { host.add_heartbeat(type: :foobar, message: message, producer: host.id) }
          let!(:heartbeat3) { host.add_heartbeat(type: :foobar, message: message, producer: host.id) }
          let!(:response) { host.find_heartbeats({ type: :foobar }, { }) }

          it { expect(response.length).to eq(2) }
        end

        context 'search heartbeats' do
          before(:each) do
            10.times do
              host.add_heartbeat(type: :comment, message: message, producer: host.id)
            end
          end

          let!(:heartbeat) { host.add_heartbeat(type: :comment, message: message, producer: host.id) }
          let!(:heartbeat2) { host.add_heartbeat(type: :comment, message: message, producer: host.id) }
          let!(:response) { host.search_heartbeats(host.id, limit: 5) }

          it { expect(response.length).to eq(5) }
        end
      end

      context 'for gateway' do
        it { expect(gateway_heartbeat.type).to eq(:change) }
        it { expect(gateway_heartbeat.message).to eq(message) }
        it { expect(gateway_heartbeat.proprietor).to eq(gateway_id: gateway.id) }

        context 'get heartbeat' do
          let!(:heartbeat) { gateway.add_heartbeat(type: :comment, message: message, producer: gateway.id) }
          let!(:response) { gateway.get_heartbeat(heartbeat.id) }

          it { expect(response.id).to eq(heartbeat.id) }
          it { expect(response.type).to eq(heartbeat.type) }
          it { expect(response.message).to eq(heartbeat.message) }
        end

        context 'get heartbeats' do
          let!(:response) { gateway.get_heartbeats }

          it { expect(response.length).to eq(1) }
        end

        context 'find heartbeats' do
          let!(:heartbeat) { gateway.add_heartbeat(type: :comment, message: message, producer: gateway.id) }
          let!(:heartbeat2) { gateway.add_heartbeat(type: :foobar, message: message, producer: gateway.id) }
          let!(:heartbeat3) { gateway.add_heartbeat(type: :foobar, message: message, producer: gateway.id) }
          let!(:response) { host.find_heartbeats({ type: :comment }, limit: 1) }

          it { expect(response.length).to eq(1) }
        end

        context 'search heartbeats' do
          before(:each) do
            10.times do
              gateway.add_heartbeat(type: :comment, message: message, producer: gateway.id)
            end
          end
          let!(:response) { gateway.search_heartbeats(gateway.id, limit: 5) }

          it { expect(response.length).to eq(5) }
        end
      end
    end
  end
end