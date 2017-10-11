module Mirage
  module Helpers
    module MethodBuilder
      def builder_methods *method_names

        defaulted = Object.new

        method_names.each do |method_name|
          method_name = method_name.to_sym
          define_method method_name do |arg = defaulted|
            return instance_variable_get("@#{method_name}".to_sym) if arg == defaulted
            instance_variable_set("@#{method_name}".to_sym, arg)
            self
          end
        end

      end
      alias builder_method builder_methods
    end
  end
end