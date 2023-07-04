module Pubid::Core
  class Transformer < Parslet::Transform
    class << self
      def get_amendment_class
        Amendment
      end

      def get_corrigendum_class
        Corrigendum
      end
    end

    def initialize
      super

      rule(amendments: subtree(:amendments)) do |context|
        if context[:amendments].is_a?(Array)
          context[:amendments] = context[:amendments].map do |amendment|
            self.class.get_amendment_class.new(number: amendment[:number], year: amendment[:year])
          end
        else
          context[:amendments] =
            [self.class.get_amendment_class.new(
              number: context[:amendments][:number],
              year: context[:amendments][:year])]

        end
        context
      end

      rule(corrigendums: subtree(:corrigendums)) do |context|
        if context[:corrigendums].is_a?(Array)
          context[:corrigendums] = context[:corrigendums].map do |corrigendum|
            self.class.get_corrigendum_class.new(number: corrigendum[:number], year: corrigendum[:year])
          end
        else
          context[:corrigendums] =
            [self.class.get_corrigendum_class.new(
              number: context[:corrigendums][:number],
              year: context[:corrigendums][:year])]
        end
        context
      end

      rule(roman_numerals: simple(:roman_numerals)) do |context|
        roman_to_int(context[:roman_numerals])
      end
    end

    ROMAN_TO_INT = {
      "I" => 1,
      "V" => 5,
      "X" => 10,
      "L" => 50,
      "C" => 100,
      "D" => 500,
      "M" => 1000,
    }

    def roman_to_int(roman)
      sum = ROMAN_TO_INT[roman.to_s[0]]
      roman.to_s.chars.each_cons(2) do |c1, c2|
        sum += ROMAN_TO_INT[c2]
        sum -= ROMAN_TO_INT[c1] * 2 if ROMAN_TO_INT[c1] < ROMAN_TO_INT[c2]
      end
      sum
    end
  end
end
