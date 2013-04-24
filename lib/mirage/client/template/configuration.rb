module Mirage
  class Template
    class Configuration
      attr_accessor :http_method, :status, :delay, :content_type, :default
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

    end
  end
end