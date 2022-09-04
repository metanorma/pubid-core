module Pubid::Core::Renderer
  class Base
    attr_accessor :params

    LANGUAGES = {
      "ru" => "R",
      "fr" => "F",
      "en" => "E",
      "ar" => "A",
    }.freeze

    def initialize(params)
      @params = params
    end

    def prerender_params(params, opts)
      params.map do |key, value|
        next unless value
        if respond_to?("render_#{key}")
          [key, send("render_#{key}", value, opts, params)]
        else
          [key, value]
        end
      end.compact.to_h
    end

    # Render identifier
    # @param with_date [Boolean] include year in output
    # @param with_language_code [:iso,:single] render document language as 2-letter ISO 639-1 language code or single code
    def render(with_date: true, with_language_code: :iso)
      params = prerender_params(@params,
                                { with_date: with_date, with_language_code: with_language_code })
      # render empty string when the key is not exist
      params.default = ""

      render_identifier(params)
    end

    def render_base(params, prefix = "")
      "%{publisher}%{copublisher}#{prefix} %{number}" % params
    end

    def render_identifier(params)
      render_base(params)
    end

    def render_copublisher(copublisher, _opts, _params)
      # (!@copublisher.is_a?(Array) && [@copublisher]) || @copublisher
      if copublisher.is_a?(Array)
        copublisher.map(&:to_s).sort.map do |copublisher|
          "/#{copublisher.gsub('-', '/')}"
        end.join
      else
        "/#{copublisher}"
      end
    end

    def render_amendments(amendments, _opts, _params)
      amendments.sort.map(&:render_pubid).join("+")
    end

    def render_corrigendums(corrigendums, _opts, _params)
      corrigendums.sort.map(&:render_pubid).join("+")
    end


    def render_part(part, opts, _params)
      "-#{part}"
    end

    def render_year(year, opts, _params)
      opts[:with_date] && ":#{year}" || ""
    end

    def render_language(language, opts, _params)
      if opts[:with_language_code] == :single
        "(#{LANGUAGES[language]})"
      else
        "(#{language})"
      end
    end
  end
end
