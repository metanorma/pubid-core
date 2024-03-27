module Pubid::Core
  class Configuration
    attr_accessor :stages, :default_type, :type_class, :types, :type_names,
                  :stage_class, :typed_stage_class, :prefixes, :identifier_module

    def initialize
      @identifier_module = identifier_module
      @type_class = Pubid::Core::Type
      @stage_class = Pubid::Core::Stage
      @typed_stage_class = Pubid::Core::TypedStage
      @types = []
    end

    def prefixes
      # return default prefix using module name e.g.
      # "ISO" for Pubid::Iso::Identifier
      # "CORE" for Pubid::Core::TestIdentifier
      @prefixes || [@identifier_module.to_s.split("::")[1].upcase]
    end

    def typed_stages
      types.inject({}) do |res, type|
        res.merge(type::TYPED_STAGES)
      end
    end
  end
end
