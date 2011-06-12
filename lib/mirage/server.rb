$LOAD_PATH.unshift "#{File.dirname(__FILE__)}"
require 'object'
require 'mock_response'
require 'mock_responses_collection'
require 'core'

module Mirage
  class << self
    def prime
      yield @client
    end

    def client= client
      @client = client
    end
  end
end
