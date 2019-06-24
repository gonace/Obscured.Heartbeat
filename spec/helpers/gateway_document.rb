# frozen_string_literal: true

module Obscured
  class Gateway
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoid::Heartbeat::Tracker

    store_in collection: 'gateways'

    field :name, type: String
    field :hostname, type: String
  end
end