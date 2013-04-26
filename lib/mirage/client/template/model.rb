
require 'client/helpers/method_builder'
require 'client/template/model/class_methods'
require 'client/template/model/instance_methods'

module Mirage
  class Template
    module Model

      class << self
        def extended clazz
          clazz.extend(ClassMethods)
          clazz.send(:include, HTTParty)
          clazz.send(:include, InstanceMethods)

          mod = Module.new do
            def initialize *args
              super self.class.endpoint, ''
              status self.class.status if self.class.status
            end
          end

          clazz.send(:include, mod)

          clazz.format :json
          clazz
        end
      end
    end

  end
end