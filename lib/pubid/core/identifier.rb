module Pubid::Core
  class Identifier
    attr_accessor :number, :publisher, :copublisher, :part,
                  :type, :year, :edition, :language, :amendments,
                  :corrigendums

    # Creates new identifier from options provided:
    # @param publisher [String] document's publisher, eg. "ISO"
    # @param copublisher [String] document's copublisher, eg. "IEC"
    # @param number [Integer] document's number, eg. "1234"
    # @param part [String] document's part and subparts, eg. "1", "1-1A", "2-3D"
    # @param type [String] document's type, eg. "TR", "TS"
    # @param year [Integer] document's year, eg. "2020"
    # @param edition [Integer] document's edition, eg. "1"
    # @param language [String] document's translation language
    #   (available languages: "ru", "fr", "en", "ar")
    # @param amendments [Array<Amendment>] document's amendments
    # @param corrigendums [Array<Corrigendum>] document's corrigendums
    # @see Amendment
    # @see Corrigendum
    def initialize(publisher:, number:, copublisher: nil, part: nil, type: nil,
                   year: nil, edition: nil, language: nil, amendments: nil,
                   corrigendums: nil)
      if amendments
        @amendments = if amendments.is_a?(Array)
                        amendments.map do |amendment|
                          self.class.get_amendment_class.new(**amendment)
                        end
                      else
                        [self.class.get_amendment_class.new(**amendments)]
                      end
      end
      if corrigendums
        @corrigendums = if corrigendums.is_a?(Array)
                          corrigendums.map do |corrigendum|
                            self.class.get_corrigendum_class.new(**corrigendum)
                          end
                        else
                          [self.class.get_corrigendum_class.new(**corrigendums)]
                        end
      end

      @publisher = publisher.to_s
      @number = number.to_i
      @copublisher = copublisher.to_s if copublisher
      @part = part.to_s if part
      @type = type.to_s if type
      @year = year.to_i if year
      @edition = edition.to_i if edition
      @language = language.to_s if language
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
        # Parslet returns an array when match any copublisher
        # otherwise it's hash
        if params.is_a?(Array)
          new(
            **(
              params.inject({}) do |r, i|
                result = r
                i.map {|k, v| get_transformer_class.new.apply(k => v).to_a.first }.each do |k, v|
                  result = result.merge(k => r.key?(k) ? [v, r[k]] : v)
                end
                result
              end
            )
          )
        else
          new(**params.map do |k, v|
            get_transformer_class.new.apply(k => v).to_a.first
          end.to_h)
        end
        # merge values repeating keys into array (for copublishers)

      rescue Parslet::ParseFailed => failure
        raise Errors::ParseError, "#{failure.message}\ncause: #{failure.parse_failure_cause.ascii_tree}"
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

      def update_old_code(code)
        return code unless defined?(UPDATE_CODES)

        UPDATE_CODES.each do |from, to|
          code = code.gsub(from.match?(/^\/.*\/$/) ? Regexp.new(from[1..-2]) : /^#{Regexp.escape(from)}$/, to)
        end
        code
      end
    end
  end
end
