require 'ostruct'
module Mirage
  class Response < OpenStruct

    attr_accessor :content_type
    attr_reader :value

    def initialize response
      @content_type = 'text/plain'
      @value = response
      super({})
    end

    def headers
      headers = {}

      @table.each { |header, value| headers["X-mirage-#{header.to_s.gsub('_', '-')}"] = value }
      headers['Content-Type']=@content_type
      headers['X-mirage-file'] = 'true' if @response.kind_of?(IO)

      headers
    end

  end
end