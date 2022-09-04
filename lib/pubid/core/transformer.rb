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
    end
  end
end
