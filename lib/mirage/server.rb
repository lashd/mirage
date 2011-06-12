require 'mirage/object'
require 'mirage/mock_response'
require 'mirage/mock_responses_collection'
require 'mirage/core'

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
