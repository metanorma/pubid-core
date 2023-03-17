module Pubid::Core
  module Errors
    class ParseError < StandardError; end
    class HarmonizedStageCodeInvalidError < StandardError; end
    class StageInvalidError < StandardError; end
    class HarmonizedStageRenderingError < StandardError; end
    class ParseTypeError < StandardError; end
    class TypeStageParseError < StandardError; end
    class WrongTypeError < StandardError; end

  end
end
