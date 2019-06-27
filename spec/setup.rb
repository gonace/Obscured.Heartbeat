# frozen_string_literal: true

$LOAD_PATH.unshift File.dirname(__FILE__)
require 'factory_bot'
require 'pp'
require 'rspec'
require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'

  track_files '{lib}/**/*.rb'
end

# pull in the code
Dir.glob('./lib/*.rb').sort.each(&method(:require))

Mongoid.load!(File.join(File.dirname(__FILE__), '/config/mongoid.yml'), 'spec')
Mongo::Logger.logger.level = Logger::ERROR

RSpec.configure do |c|
  c.order = :random
  c.filter_run :focus
  c.run_all_when_everything_filtered = true

  c.include FactoryBot::Syntax::Methods

  c.before(:suite) do
    FactoryBot.find_definitions
    Mongoid.purge!

    Mongoid::Search.setup do |cfg|
      cfg.strip_symbols = /[\"]/
      cfg.strip_accents = //
    end
  end

  c.before(:each) do
    Mongoid.purge!
  end

  c.after(:suite) do
    Mongoid.purge!
  end
end