module Pubid::Core
  class Entity
    def ==(other)
      instance_variables.map do |var|
        return false unless instance_variable_get(var) == other.instance_variable_get(var)
      end

      true
    end
  end
end
