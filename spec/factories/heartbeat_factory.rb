# frozen_string_literal: true

require_relative '../../lib/obscured-heartbeat/record'

FactoryBot.define do
  factory :heartbeat, class: Mongoid::Heartbeat::Record do
    distribution {
      {
        name: 'Ubuntu',
        release: '19.04',
        codename: 'disco',
        description: 'Ubuntu 19.04'
      }
    }
    hostname { 'host.domain.tld' }
    ip_address { '10.0.1.1' }
    uptime { 1561391862 }

    trait :with_host do
      proprietor { { host_id: BSON::ObjectId.new } }
    end
  end
end