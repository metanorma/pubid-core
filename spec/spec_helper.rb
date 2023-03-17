# frozen_string_literal: true

require "bundler/setup"
require "rspec/matchers"

require_relative "../lib/pubid-core"

Dir["./spec/support/**/*.rb"].sort.each { |f| require f }

