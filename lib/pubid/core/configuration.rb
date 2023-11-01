module Pubid::Core
  class Configuration
    attr_accessor :stages, :default_type, :type_class, :types, :type_names, :stage_class, :typed_stage_class

    def initialize
      @type_class = Pubid::Core::Type
      @stage_class = Pubid::Core::Stage
      @typed_stage_class = Pubid::Core::TypedStage
      @types = []
    end

    def typed_stages
      types.inject({}) do |res, type|
        res.merge(type::TYPED_STAGES)
      end
    end
  end
end
