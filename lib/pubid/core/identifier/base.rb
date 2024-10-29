module Pubid::Core
  module Identifier
    class Base
      attr_accessor :number, :publisher, :copublisher, :part, :year, :edition, :language, :amendments,
                    :corrigendums, :stage

      TYPED_STAGES = {}.freeze

      # Creates new identifier from options provided:
      # @param publisher [String] document's publisher, eg. "ISO"
      # @param copublisher [String,Array<String>] document's copublisher, eg. "IEC"
      # @param number [Integer] document's number, eg. "1234"
      # @param part [String] document's part and subparts, eg. "1", "1-1A", "2-3D"
      # @param type [String] document's type, eg. "TR", "TS"
      # @param year [Integer] document's year, eg. "2020"
      # @param edition [Integer] document's edition, eg. "1"
      # @param language [String] document's translation language
      #   (available languages: "ru", "fr", "en", "ar")
      # @param amendments [Array<Amendment>,Array<Hash>] document's amendments
      # @param corrigendums [Array<Corrigendum>,Array<Hash>] document's corrigendums
      # @see Amendment
      # @see Corrigendum
      def initialize(publisher:, number:, copublisher: nil, part: nil,
                     year: nil, edition: nil, language: nil, amendments: nil,
                     corrigendums: nil, stage: nil)

        if amendments
          @amendments = amendments.map do |amendment|
            if amendment.is_a?(Hash)
              self.class.get_transformer_class.new.apply(:amendments => [amendment])[:amendments].first
            else
              amendment
            end
          end
        end

        if corrigendums
          @corrigendums = corrigendums.map do |corrigendum|
            if corrigendum.is_a?(Hash)
              self.class.get_transformer_class.new.apply(:corrigendums => [corrigendum])[:corrigendums].first
            else
              corrigendum
            end
          end
        end

        @publisher = publisher.to_s
        @number = number&.to_s
        @copublisher = copublisher if copublisher
        @part = part.to_s if part
        @year = year.to_i if year
        @edition = edition.to_i if edition
        @language = language.to_s if language

        @stage = resolve_stage(stage) if stage
      end

      # @return [String] Rendered URN identifier
      def urn
        Renderer::Urn.new(to_h).render
      end

      # @return [Hash] Identifier's parameters
      def to_h(deep: true, add_type: true)
        result = instance_variables.map do |var|
          value = instance_variable_get(var)

          [var.to_s.gsub("@", "").to_sym,
           if value.is_a?(Array)
             value.map { |v| (v.respond_to?(:to_h) && deep) ? v.to_h : v }
           elsif value.nil?
             nil
           else
             (value.respond_to?(:to_h) && deep) ? value.to_h : value
           end
          ]
        end.to_h

        if add_type && respond_to?(:type) && type[:short]
          result[:type] = type[:short]
        end

        result.reject { |k, v| k != :number && v.nil? }
      end

      def to_yaml
        # use #to_h for serialization to avoid !ruby/object in output
        to_h.to_yaml
      end

      def ==(other)
        case other
        when String
          to_s == other
        when Identifier::Base
          to_h == other.to_h
        when Hash
          to_h == other
        else
          raise Errors::WrongTypeError, "cannot compare with #{other.class} type"
        end
      end

      # Render identifier using default renderer
      def to_s
        self.class.get_renderer_class.new(to_h(deep: false)).render
      end

      def exclude(*args)
        nested_exclusions, top_level_exclusions = args.partition { |arg| arg.is_a?(Hash) }

        nested_exclusions = nested_exclusions.reduce({}, :merge)

        excluded_hash = to_h(add_type: false)
          .reject { |k, v| top_level_exclusions.include?(k) }
          .each_with_object({}) do |(k, v), memo|
            memo[k] = if v.is_a?(Hash) && nested_exclusions.key?(k)
                        v.reject { |key, _| nested_exclusions[k].include?(key) }
                      else
                        v
                      end
          end

        self.class.new(**excluded_hash)
      end

      def typed_stage_abbrev
        if stage.is_a?(TypedStage)
          return stage.to_s
        end

        stage ? "#{stage.abbr} #{self.class.type[:key].to_s.upcase}" : self.class.type[:key].to_s.upcase
      end

      # Return typed stage name, eg. "Final Draft Technical Report" for "FDTR"
      def typed_stage_name
        if stage.is_a?(TypedStage) && self.class::TYPED_STAGES.key?(stage.abbr)
          return self.class::TYPED_STAGES[stage.abbr][:name]
        end

        stage ? "#{stage.name} #{self.class.type[:title]}" : self.class.type[:title]
      end

      # @param stage [Stage, Symbol, String] stage or typed stage, e.g. "PWI", "NP", "50.00", Stage.new(abbr: :WD), "DTR"
      # @return [[nil, Stage], [Symbol, Stage]] typed stage and stage values
      def resolve_stage(stage)
        if stage.is_a?(Stage)
          return self.class.resolve_typed_stage(stage.harmonized_code) || stage unless stage.abbr

          return stage
        end

        if self.class.has_typed_stage?(stage)
          return self.class.find_typed_stage(stage)
        end

        parsed_stage = self.class.get_identifier.parse_stage(stage)
        # resolve typed stage when harmonized code provided as stage
        # or stage abbreviation was not resolved
        if /\A[\d.]+\z/.match?(stage) || parsed_stage.empty_abbr?(with_prf: true)
          return self.class.resolve_typed_stage(parsed_stage.harmonized_code) || parsed_stage
        end

        parsed_stage

        # from IEC
        # @typed_stage = self.class::TYPED_STAGES[@typed_stage][:abbr] if @typed_stage
      end

      # Checks if another identifier is newer edition of the same document
      # @param other [Pubid::Core::Identifier::Base] pubid identifier to compare with
      # @return [Boolean] true if another identifier is newer edition
      def new_edition_of?(other)
        if exclude(:year, :edition) != other.exclude(:year, :edition)
          raise Errors::AnotherDocumentError, "cannot compare edition with #{other}"
        end

        if year.nil? || other.year.nil?
          raise Errors::CannotCompareError, "cannot compare identifier without edition year"
        end

        if year == other.year && (edition || other.edition)
          return false if other.edition.nil?

          return true if edition.nil?

          return edition > other.edition
        end

        year > other.year
      end

      # returns root identifier
      def root
        return base.base if base&.class&.method_defined?(:base) && base&.base

        base || self
      end

      class << self
        # Parses given identifier
        # @param code_or_params [String, Hash] code or hash from parser
        #   eg. "ISO 1234", { }
        # @return [Pubid::Core::Identifier] identifier
        def parse(code_or_params)
          params = code_or_params.is_a?(String) ?
                     get_parser_class.new.parse(update_old_code(code_or_params)) : code_or_params
          transform(params.is_a?(Array) ? array_to_hash(params) : params)
        rescue Parslet::ParseFailed => failure
          raise Errors::ParseError, "#{failure.message}\ncause: #{failure.parse_failure_cause.ascii_tree}"
        end

        # Converts array of hashes into single hash
        # array like [{ publisher: "ISO" }, { number: 1 }] to hash { publisher: "ISO", number: 1 }
        # @param params [Array<Hash>] input array of hashes, eg. [{ a: 1 }, { b: 2 }]
        def array_to_hash(params)
          params.inject({}) do |r, i|
            result = r
            i.each do |k, v|
              result = result.merge(k => r.key?(k) ? [r[k], v].flatten : v)
            end
            result
          end
        end

        # Transform parameters hash or array or hashes to identifier
        def transform(params)
          # run transform through each element,
          # like running transformer.apply(number: 1) and transformer.apply(year: 1999)
          # instead of running transformer on whole hash, like running transformer.apply({ number: 1, year: 1999 })
          # where rule for number or year only will be not applied
          # transformation only applied to rules matching the whole hash

          identifier_params = params.map do |k, v|
                                get_transformer_class.new.apply(k => v).to_a.first
                              end.to_h

          new(**identifier_params)
        end

        # @param type [Symbol, String] eg. :tr, :ts, "TS"
        # @return [Boolean] true if provided type matches with identifier's class type
        def has_type?(type)
          return type == self.type[:key] if type.is_a?(Symbol)

          self.type.key?(:values) ? self.type[:values].include?(type) : type.to_s.downcase.to_sym == self.type[:key]
        end

        def get_amendment_class
          Amendment
        end

        def get_corrigendum_class
          Corrigendum
        end

        def get_renderer_class
          Renderer::Base
        end

        def get_transformer_class
          Transformer
        end

        # @return [Hash, nil] replacement patterns
        def get_update_codes
          nil
        end

        def get_identifier
          Identifier
        end

        def update_old_code(code)
          return code unless get_update_codes

          get_update_codes.each do |from, to|
            code = code.gsub(from.match?(/^\/.*\/$/) ? Regexp.new(from[1..-2]) : /^#{Regexp.escape(from)}$/, to)
          end
          code
        end

        # @param typed_stage [String, Symbol] typed stage, eg. "DTR" or :dtr
        # @return [Boolean] true when identifier has associated typed stage
        def has_typed_stage?(typed_stage)
          return self::TYPED_STAGES.key?(typed_stage) if typed_stage.is_a?(Symbol)

          self::TYPED_STAGES.any? do |_, v|
            if v[:abbr].is_a?(Hash)
              v[:abbr].value?(typed_stage)
            else
              if v.key?(:legacy_abbr)
                v[:legacy_abbr].include?(typed_stage) || v[:abbr] == typed_stage
              else
                v[:abbr] == typed_stage
              end
            end
          end
        end

        # Returns true when identifier's type match with provided parameters
        def type_match?(parameters)
          parameters[:type] ? has_type?(parameters[:type]) : has_typed_stage?(parameters[:stage])
        end

        # @param typed_stage [String, Symbol] eg. "DTR" or :dtr
        # @return [[Symbol, Stage]] typed stage and stage with assigned harmonized codes
        def find_typed_stage(typed_stage)
          if typed_stage.is_a?(Symbol)
            return get_identifier
                .build_typed_stage(
                  harmonized_code:
                    get_identifier.build_harmonized_stage_code(self::TYPED_STAGES[typed_stage][:harmonized_stages]),
                  abbr: typed_stage,
                )
          end

          typed_stage = self::TYPED_STAGES.find do |_, v|
            if v[:abbr].is_a?(Hash)
              v[:abbr].value?(typed_stage)
            elsif v.key?(:legacy_abbr)
              v[:legacy_abbr].include?(typed_stage) || v[:abbr] == typed_stage
            else
              v[:abbr] == typed_stage
            end
          end

          get_identifier.build_typed_stage(harmonized_code:
                                       get_identifier.build_harmonized_stage_code(typed_stage[1][:harmonized_stages]),
                                     abbr: typed_stage.first)
        end

        # Resolve typed stage using stage harmonized stage code
        # @param harmonized_code [HarmonizedStageCode]
        # @return [Symbol, nil] typed stage or nil
        def resolve_typed_stage(harmonized_code)
          self::TYPED_STAGES.each do |k, v|
            if (v[:harmonized_stages] & harmonized_code.stages) == harmonized_code.stages
              return get_identifier.build_typed_stage(abbr: k, harmonized_code: harmonized_code)
            end
          end
          nil
        end
      end
    end
  end
end
