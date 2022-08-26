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
            self.class.get_amendment_class.new(version: amendment[:version], number: amendment[:number])
          end
        else
          context[:amendments] =
            [self.class.get_amendment_class.new(
              version: context[:amendments][:version],
              number: context[:amendments][:number])]

        end
        context
      end

      rule(corrigendums: subtree(:corrigendums)) do |context|
        if context[:corrigendums].is_a?(Array)
          context[:corrigendums] = context[:corrigendums].map do |corrigendum|
            self.class.get_corrigendum_class.new(version: corrigendum[:version], number: corrigendum[:number])
          end
        else
          context[:corrigendums] =
            [self.class.get_corrigendum_class.new(
              version: context[:corrigendums][:version],
              number: context[:corrigendums][:number])]
        end
        context
      end
    end
  end
end
