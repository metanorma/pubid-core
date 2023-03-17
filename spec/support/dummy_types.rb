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

    def self.type
      { key: :tr, title: "Technical Report" }
    end
  end
end

