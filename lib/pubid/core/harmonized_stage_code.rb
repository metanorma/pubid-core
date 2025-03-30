module Pubid::Core
  class HarmonizedStageCode
    include Comparable
    # attr_accessor :stage, :substage
    attr_accessor :config, :stages, :harmonized_typed_stages

    # @param stage_or_code [String,Array<String>] stage number or whole harmonized code with substage
    #   or list or stages for fuzzy stages eg. "10", 10, "20.20", ["10.20", "20.20"]
    #   or stage name eg. "proposal", "approval"
    #   or typed stages eg. :dtr, :fdis
    # @param substage [Integer, String] eg. "00", 0
    #   or substage name eg. "registration", "start_of_main_action"
    def initialize(stage_or_code, substage = "00", config:)
      @config = config
      @stages = if stage_or_code.is_a?(Array)
                  stage_or_code
                elsif stage_or_code.is_a?(String) && (
                  config.stages["codes_description"].key?(stage_or_code) ||
                    harmonized_typed_stages.include?(stage_or_code))
                  [stage_or_code]
                # when stage is typed stage
                elsif stage_or_code.is_a?(Symbol) && config.typed_stages.key?(stage_or_code)
                  config.typed_stages[stage_or_code][:harmonized_stages]
                # when stage is stage name
                elsif config.stages["stage_codes"]&.key?(stage_or_code.to_s)
                  ["#{config.stages["stage_codes"][stage_or_code.to_s]}.#{config.stages["substage_codes"][substage.to_s]}"]
                else
                  # stage is number
                  ["#{stage_or_code}.#{substage}"]
                end
      validate_stages
    end

    def harmonized_typed_stages
      @harmonized_typed_stages ||= config.typed_stages.values.map { |v| v[:harmonized_stages] }.flatten
    end

    def validate_stages
      @stages.each do |stage|
        # raise an error when stage is wrong
        next if config.stages["codes_description"].key?(stage)

        # check typed stages if no stages in config
        next if harmonized_typed_stages.include?(stage)

        raise Errors::HarmonizedStageCodeInvalidError
      end
    end

    def to_s
      if fuzzy?
        return "draft" if @stages.all? { |s| config.stages["draft_codes"].include?(s) || config.stages["canceled_codes"].include?(s) }

        return "published" if @stages.all? { |s| config.stages["published_codes"].include?(s) }

        raise Errors::HarmonizedStageRenderingError, "cannot render fuzzy stages"
      else
        @stages.first
      end
    end

    def ==(other)
      (stages & other.stages) == other.stages
    end

    def fuzzy?
      @stages.length > 1 || @stages.none?
    end

    def stage
      raise Errors::HarmonizedStageRenderingError, "cannot render stage for fuzzy stages" if fuzzy?

      return nil if @stages.empty?

      @stages.first.split(".").first
    end

    def substage
      raise Errors::HarmonizedStageRenderingError, "cannot render substage for fuzzy stages" if fuzzy?

      @stages.first.split(".").last
    end

    def description
      config.stages["codes_description"][to_s]
    end
  end
end
