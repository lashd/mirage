module Mirage
  class MirageError < ::Exception
    attr_reader :code

    def initialize message, code
      super message
      @code = message, code
    end
  end

  class InternalServerException < MirageError;
  end

  class ResponseNotFound < MirageError;
  end

  class ClientError < ::Exception
    def initialize message
      super message
    end
  end
end