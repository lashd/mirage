module Mirage
  class Template
    module Model
      module ClassMethods
        extend Helpers::MethodBuilder
        include Helpers::MethodBuilder
        builder_method :endpoint, :status
      end
    end
  end
end