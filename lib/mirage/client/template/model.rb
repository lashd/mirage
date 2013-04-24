
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

          clazz.class_eval do
            def initialize
              super self.class.endpoint, ''
              status self.class.status if self.class.status
            end
          end

          clazz.format :json
          clazz
        end
      end
    end

  end
end