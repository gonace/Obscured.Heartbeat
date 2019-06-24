# frozen_string_literal: true

require_relative '../helpers/host_document'

FactoryBot.define do
  factory :host, class: Obscured::Host do
    name { 'host' }
    hostname { 'hostname.domain.tld' }
  end
end