module Mirage
  class Template
    module Model
      module ClassMethods
        def endpoint endpoint =nil
          return @endpoint unless endpoint
          @endpoint = endpoint
        end

        def status status =nil
          return @status unless status
          @status = status
        end
      end
    end
  end
end