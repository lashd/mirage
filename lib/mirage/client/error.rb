module Mirage
  class MirageError < ::Exception
    attr_reader :code

    def initialize message, code
      super message
      @code = message, code
    end
  end

  class InternalServerException < MirageError
  end

  class TemplateNotFound < ::Exception
  end

  class ClientError < ::Exception
    def initialize message
      super message
    end
  end
end