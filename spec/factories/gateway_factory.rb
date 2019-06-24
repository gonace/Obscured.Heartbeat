# frozen_string_literal: true

require_relative '../helpers/gateway_document'

FactoryBot.define do
  factory :gateway, class: Obscured::Gateway do
    name { 'Gateway Sweden' }
    hostname { 'gateway.domain.tld' }
  end
end