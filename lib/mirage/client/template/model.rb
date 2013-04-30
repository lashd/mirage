require 'client/helpers/method_builder'
require 'client/template/model/common_methods'
require 'client/template/model/instance_methods'

module Mirage
  class Template
    module Model

      class << self
        def extended clazz
          clazz.extend(CommonMethods)
          clazz.extend(Helpers::MethodBuilder)
          clazz.send(:include, HTTParty)
          clazz.send(:include, CommonMethods)
          clazz.send(:include, InstanceMethods)


          mod = Module.new do
            def initialize *args

              super *args
              [:content_type,
               :http_method,
               :default,
               :status,
               :delay,
               :required_parameters,
               :required_body_content,
               :required_headers,
               :headers,
               :endpoint, :delay].each do |attribute|
                eval("#{attribute} self.class.#{attribute} if self.class.#{attribute}")
              end


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