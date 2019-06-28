# frozen_string_literal: true

require 'mongoid'
require 'mongoid_search'

Mongoid::Search.setup do |cfg|
  cfg.strip_symbols = /["]/
  cfg.strip_accents = //
end

require 'obscured-heartbeat/record'
require 'obscured-heartbeat/service'
require 'obscured-heartbeat/tracker'

module Mongoid
  module Heartbeat
  end
end
