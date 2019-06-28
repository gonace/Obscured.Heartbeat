# frozen_string_literal: true

require_relative 'setup'
require_relative 'helpers/host_document'
require_relative 'helpers/host_service'


describe Mongoid::Heartbeat::Service::Host do
  let!(:host) { FactoryBot.create(:host) }
  let!(:host2) { FactoryBot.create(:host, hostname: 'host2.domain.tld') }
  let!(:service) { Mongoid::Heartbeat::Service::Host.new }
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

  before(:each) do
    5.times do
      host.add_heartbeat(template)
    end

    3.times do
      host2.add_heartbeat(template.merge(hostname: host2.hostname))
    end
  end

  describe 'all' do
    let(:response) { service.all }

    it { expect(response.to_a.count).to eq(8) }
  end

  describe 'find' do
    let!(:heartbeat) { host.add_heartbeat(template) }
    let(:response) { service.find(heartbeat.id) }

    it { expect(response).to_not be(nil) }
    it { expect(response.id).to eq(heartbeat.id) }
  end

  describe 'find_by' do
    let!(:heartbeat) { host.add_heartbeat(template) }
    let(:response) { service.find_by(hostname: 'host.domain.tld') }

    it { expect(response).to_not be(nil) }
    it { expect(response.count).to eq(1) }
  end

  describe 'by' do
    context 'proprietor' do
      let(:response) { service.by(proprietor: { host_id: host.id }) }

      it { expect(response.count).to eq(5) }
    end
  end

  describe 'where' do
    context 'returns correct documents' do
      let(:response) { service.where(hostname: 'host2.domain.tld') }

      it { expect(response.count).to eq(3) }
    end
  end

  describe 'delete' do
    context 'deletes document by id' do
      let!(:heartbeat) { host.add_heartbeat(template) }

      it { expect(service.delete(heartbeat.id)).to eq(1) }
    end
  end
end