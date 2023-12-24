module Pubid::Core
  class TypedStage < Stage
    attr_accessor :config, :abbr

    # @param config [Configuration]
    # @param abbr [Symbol] typed stage symbol, e.g. :dtr
    # @param harmonized_code [String, Float, HarmonizedStageCode]
    def initialize(config:, abbr: nil, harmonized_code: nil)
      @config = config
      @abbr = abbr

      if harmonized_code
        @harmonized_code = if harmonized_code.is_a?(HarmonizedStageCode)
                             harmonized_code
                           else
                             HarmonizedStageCode.new(harmonized_code, config: config)
                           end
        @abbr ||= lookup_abbr(@harmonized_code.stages)
      end

      if abbr && !config.typed_stages.key?(abbr)
        raise Errors::TypedStageInvalidError, "#{abbr} is not valid typed stage"
      end

      @harmonized_code ||= HarmonizedStageCode.new(abbr, config: config)
    end

    def lookup_abbr(lookup_code)
      lookup_code = lookup_code.first if lookup_code.is_a?(Array) && lookup_code.count == 1

      config.typed_stages.each do |abbr, stage|
        return abbr if stage[:harmonized_stages].include?(lookup_code)
      end

      nil
    end

    # Compares one stage with another
    # should return false if
    def ==(other)
      return false unless other.is_a?(self.class)

      # return abbr == other if other.is_a?(Symbol)

      other&.harmonized_code == harmonized_code
    end

    def to_s(_opts = nil)
      config.typed_stages[abbr][:abbr]
    end
  end
end
