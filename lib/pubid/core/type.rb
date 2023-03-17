module Pubid::Core
  class Type
    attr_accessor :type, :config

    # Create new type
    # @param type [Symbol]
    def initialize(type = nil, config:)
      @config = config
      if type.nil?
        type = @config.default_type.type[:key]
      end
      type = type.to_s.downcase.to_sym unless type.is_a?(Symbol)

      raise Errors::WrongTypeError, "#{type} type is not available" unless @config.type_names.key?(type)

      @type = type
    end

    def self.parse(type_string, config:)
      config.type_names.each do |type, values|
        return new(type, config: config) if values[:short] == type_string
      end
      raise Errors::ParseTypeError, "Cannot parse '#{type_string}' type"
    end

    def to_s(format = :short)
      @config.type_names[type][format]
    end

    def ==(other)
      return type == other if other.is_a?(Symbol)

      return false if other.nil?

      type == other.type
    end

    def self.has_type?(type, config:)
      config.type_names.any? do |_, v|
        v[:short] == type
      end
    end
  end
end
