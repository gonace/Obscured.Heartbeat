# frozen_string_literal: true

module Obscured
  class Host
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoid::Heartbeat::Tracker

    store_in collection: 'hosts'

    field :name, type: String
    field :hostname, type: String
  end
end