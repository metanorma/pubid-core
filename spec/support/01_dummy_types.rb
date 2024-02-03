require 'forwardable'

module Pubid::Core
  class DummyDefaultType < Identifier::Base
    extend Forwardable
    def_delegators 'Pubid::Core::DummyDefaultType', :type

    def self.type
      { key: :default, title: "Default Type" }
    end
  end

  class DummyTechnicalReportType < Identifier::Base
    extend Forwardable
    def_delegators 'Pubid::Core::DummyTechnicalReportType', :type

    TYPED_STAGES = {
      dtr: {
        abbr: "DTR",
        name: "Draft Technical Report",
        harmonized_stages: %w[40.00],
      },
    }.freeze

    def self.get_identifier
      DummyTestIdentifier
    end

    def self.type
      { key: :tr, title: "Technical Report", short: "TR" }
    end
  end

  class DummyInternationalStandardType < Identifier::Base
    extend Forwardable
    def_delegators 'Pubid::Core::DummyInternationalStandardType', :type

    TYPED_STAGES = {
      dp: {
        abbr: "DP",
        name: "Draft Proposal",
        harmonized_stages: %w[],
      },
      dis: {
        abbr: "DIS",
        name: "Draft International Standard",
        harmonized_stages: %w[40.00 40.20 40.60 40.92 40.93 40.98 40.99],
      },
      fdis: {
        abbr: "FDIS",
        name: "Final Draft International Standard",
        harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99],
      },
    }.freeze

    def self.type
      { key: :is, title: "International Standard", short: nil }
    end
  end

  class DummyAmendment < Identifier::Base
    extend Forwardable
    def_delegators 'Pubid::Core::DummyAmendment', :type

    attr_accessor :base

    def initialize(base: nil, **opts)
      @base = base
      super(**opts)
    end

    def self.type
      { key: :amd, title: "Amendment", short: "Amd" }
    end
  end

  module DummyTestIdentifier
    class << self
      include Pubid::Core::Identifier
    end
  end
end

