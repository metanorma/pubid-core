module Pubid::Core
  module Identifier
    attr_accessor :config
    @config = nil

    # Resolve identifier's class and create new identifier
    # @see Pubid::Identifier::Base.initialize for available options
    def create(**opts)
      resolve_identifier(opts)
    end

    # @param typed_stage_or_stage [String] typed stage or stage
    # @return identifier's class
    def resolve_identifier(parameters = {})
      return @config.default_type.new(**parameters.dup.tap { |h| h.delete(:type) }) if parameters[:type].nil? && parameters[:stage].nil?

      @config.types.each do |identifier_type|
        return identifier_type.new(**parameters.dup.tap { |h| h.delete(:type) }) if identifier_type.type_match?(parameters)
      end

      # When stage is not typed stage and type is not defined
      if parameters[:type].nil? && (parameters[:stage].is_a?(Stage) || has_stage?(parameters[:stage]))
        return @config.default_type.new(stage: parameters[:stage], **parameters)
      end

      raise Errors::TypeStageParseError, "cannot parse typed stage or stage '#{parameters[:stage]}'" if parameters[:type].nil?

      raise Errors::ParseTypeError, "cannot parse type #{parameters[:type]}"
    end

    # @see Pubid::Identifier::Base.parse
    def parse(*args)
      Base.parse(*args)
    end

    # Parse identifier from title
    def set_config(config)
      @config = config
      @config.identifier_module = self
    end

    def build_stage(**args)
      @config.stage_class.new(config: @config, **args)
    end

    def parse_stage(stage)
      @config.stage_class.parse(stage, config: @config)
    end

    def has_stage?(stage)
      @config.stage_class.has_stage?(stage, config: @config)
    end

    def build_type(type, **args)
      @config.type_class.new(type, config: @config, **args)
    end

    def build_harmonized_stage_code(stage_or_code, substage = "00")
      HarmonizedStageCode.new(stage_or_code, substage, config: @config)
    end

    def build_typed_stage(**args)
      @config.typed_stage_class.new(config: @config, **args)
    end

    def parseable?(pubid)
      @config.prefixes.any? do |prefix|
        pubid.start_with?(prefix)
      end
    end
  end
end
