module Pubid::Core
  class Supplement
    include Comparable
    attr_accessor :version, :number

    # Creates new supplement with provided version and optional number
    # @param version [Integer]
    # @param number [Integer]
    def initialize(version:, number: nil)
      @version, @number = version&.to_i, number&.to_i
    end

    def <=>(other)
      return 0 if number.nil? && other.number

      return number <=> other.number if version == other.version

      (version <=> other.version) || number <=> other.number
    end

    def render_pubid_number
        if @number
          "#{@version}:#{@number}"
        else
          "#{@version}"
        end
    end

    def render_urn_number
        if @number
          ":#{@number}:v#{@version}"
        else
          ":#{@version}:v1"
        end
    end
  end
end
