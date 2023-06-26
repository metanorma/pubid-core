# frozen_string_literal: true

module Pubid
  module Core
    def self.configuration
      @configuration ||= Configuration.new
    end

    def self.configure
      yield(configuration)
    end
  end
end

require_relative "pubid/core"
