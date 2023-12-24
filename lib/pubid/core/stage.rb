module Pubid::Core
  class Stage
    attr_accessor :config, :abbr, :harmonized_code

    # @param abbr [String, Symbol] abbreviation eg. :PWI, :WD
    # @param harmonized_code [String, Float, HarmonizedStageCode]
    # @param config [Configuration]
    def initialize(config:, abbr: nil, harmonized_code: nil)
      @config = config
      @abbr = abbr&.to_s

      if harmonized_code
        @harmonized_code = if harmonized_code.is_a?(HarmonizedStageCode)
                             harmonized_code
                           else
                             HarmonizedStageCode.new(harmonized_code, config: config)
                           end
        @abbr ||= lookup_abbr(@harmonized_code.stages)
      end

      if abbr
        raise Errors::StageInvalidError, "#{abbr} is not valid stage" unless config.stages["abbreviations"].key?(abbr.to_s)

        @harmonized_code ||= HarmonizedStageCode.new(lookup_code(abbr), config: config)
      end
    end

    # Lookup for abbreviated code by numeric stage code
    # @param lookup_code [String, Array] stage code or array of stage codes,
    #   e.g. "00.00", "20.20", ["00.00", "00.20"]
    def lookup_abbr(lookup_code)
      lookup_code = lookup_code.first if lookup_code.is_a?(Array) && lookup_code.count == 1

      config.stages["abbreviations"].each do |abbr, codes|
        case codes
        when Array
          if lookup_code.is_a?(Array)
            return abbr if codes == lookup_code
          else
            return abbr if codes.include?(lookup_code)
          end
          # codes.each do |code|
          #   return abbr if code == lookup_code
          # end
        when lookup_code
          return abbr
        end
      end

      nil
    end

    def lookup_code(lookup_abbr)
      config.stages["abbreviations"][lookup_abbr.to_s]
    end

    def self.parse(stage, config:)
      if /\A[\d.]+\z/.match?(stage)
        new(harmonized_code: stage, config: config)
      else
        raise Errors::StageInvalidError unless stage.is_a?(Symbol) || stage.is_a?(String) || stage.is_a?(Parslet::Slice)

        new(abbr: stage.to_s, config: config)
      end
    end

    # @return [Boolean] true if stage exists
    def self.has_stage?(stage, config:)
      if stage.is_a?(Stage)
        config.stages["abbreviations"].key?(stage.abbr.to_sym)
      else
        config.stages["abbreviations"].key?(stage.to_s) || /\A[\d.]+\z/.match?(stage)
      end
    end

    # Compares one stage with another
    def ==(other)
      return false unless other

      unless other.is_a?(self.class)
        return false
        # other = self.class.parse(other, config: config)
      end
      other&.harmonized_code == harmonized_code
    end

    # Return stage name, eg. "Draft International Standard" for "DIS"
    def name
      config.stages["names"][abbr.to_s]
    end

    # @param with_prf [Boolean]
    # @return [Boolean] false if there are output for abbreviation should be produced
    def empty_abbr?(with_prf: false)
      return true if abbr == "PRF" && !with_prf

      abbr.nil?
    end

    def to_s(opts = {})
      empty_abbr?(**opts) ? "" : abbr
    end

    def to_h
      abbr
    end
  end
end
