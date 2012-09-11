require 'ostruct'
module Mirage
  class Response

    attr_accessor :content_type,:method, :pattern, :default, :status, :delay
    attr_reader :value

    def initialize response
      @content_type = 'text/plain'
      @value = response
      @method = :get
      @status = 200
      @delay = 0
    end

    def headers
      headers = {}
      headers['Content-Type']=@content_type
      headers['X-mirage-file'] = 'true' if @response.kind_of?(IO)
      headers['X-mirage-method'] = @method
      headers['X-mirage-pattern'] = @pattern if @pattern
      headers['X-mirage-default'] = @default if @default == true
      headers['X-mirage-status'] = @status
      headers['X-mirage-delay'] = @delay
      headers
    end

  end
end