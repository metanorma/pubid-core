module Pubid::Core
  class Edition
    include Comparable
    attr_accessor :year, :number, :config

    def initialize(config:, year: nil, number: nil)
      @config = config
      @year = year
      @number = number
    end

    def <=>(other)
      if other.year && year
        return number <=> other.number if year == other.year

        year <=> other.year
      else
        number <=> other.number
      end
    end

    # def ==(other)
    #   other.year == year && number == other.number
    # end
  end
end
