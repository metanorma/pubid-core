module Pubid::Core
  class Supplement
    include Comparable
    attr_accessor :number, :year

    # Creates new supplement with provided update number and optional year
    # @param number [Integer]
    # @param year [Integer]
    def initialize(number:, year: nil)
      @number, @year = number&.to_i, year&.to_i
    end

    def <=>(other)
      return 0 if year.nil? && other.year

      return year <=> other.year if number == other.number

      (number <=> other.number) || year <=> other.year
    end

    def render_pubid_number
        if @year
          "#{@number}:#{@year}"
        else
          "#{@number}"
        end
    end

    def render_urn_number
        if @year
          ":#{@year}:v#{@number}"
        else
          ":#{@number}:v1"
        end
    end

    def to_h
      { number: number,
        year: year }
    end
  end
end
