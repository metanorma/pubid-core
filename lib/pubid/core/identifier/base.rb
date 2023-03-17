module Pubid::Core
  module Identifier
    class Base
      attr_accessor :number, :publisher, :copublisher, :part,
                    :type, :year, :edition, :language, :amendments,
                    :corrigendums, :stage

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
      def initialize(publisher:, number:, copublisher: nil, part: nil, type: nil,
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
        @number = number
        @copublisher = copublisher if copublisher
        @part = part.to_s if part
        @type = type.to_s if type
        @year = year.to_i if year
        @edition = edition.to_i if edition
        @language = language.to_s if language
        @stage = stage if stage
      end

      # @return [String] Rendered URN identifier
      def urn
        Renderer::Urn.new(get_params).render
      end

      def get_params
        instance_variables.map { |var| [var.to_s.gsub("@", "").to_sym, instance_variable_get(var)] }.to_h
      end

      # Render identifier using default renderer
      def to_s
        self.class.get_renderer_class.new(get_params).render
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
              result = result.merge(k => r.key?(k) ? [v, r[k]].flatten : v)
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

        def update_old_code(code)
          return code unless get_update_codes

          get_update_codes.each do |from, to|
            code = code.gsub(from.match?(/^\/.*\/$/) ? Regexp.new(from[1..-2]) : /^#{Regexp.escape(from)}$/, to)
          end
          code
        end

        # Returns true when identifier's type match with provided parameters
        def type_match?(parameters)
          has_type?(parameters[:type])
        end
      end
    end
  end
end
