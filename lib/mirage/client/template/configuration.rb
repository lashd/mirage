require 'client/helpers/method_builder'

module Mirage
  class Template
    class Configuration
      extend Helpers::MethodBuilder
      builder_methods :http_method, :status, :delay, :content_type, :default
      attr_accessor :caller_binding
      DEFAULT_HTTP_METHOD=:get
      DEFAULT_STATUS=200
      DEFAULT_DELAY=0
      DEFAULT_CONTENT_TYPE="text/plain"
      DEFAULT_DEFAULT=false

      def initialize
        reset
      end

      def reset
        @http_method = DEFAULT_HTTP_METHOD
        @status = DEFAULT_STATUS
        @delay = DEFAULT_DELAY
        @content_type = DEFAULT_CONTENT_TYPE
        @default = DEFAULT_DEFAULT
      end


      def method_missing(method, *args, &block)
        @caller_binding.send method, *args, &block if @caller_binding
      end

      def == config
        config.is_a?(Configuration) &&
            http_method == config.http_method &&
            status == config.status &&
            delay == config.delay &&
            content_type == config.content_type &&
            default == config.default

      end

    end
  end
end