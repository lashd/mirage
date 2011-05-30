require 'mirage/web'
require 'mirage/util'
require 'mirage/mock_response'
require 'mirage/mock_responses_collection'
require 'mirage/core'
require 'mirage/client'

module Mirage
  # When mirage starts it loads any ruby files found in the responses directory. Use this method to get hold of a client configured for the running server.
  def self.prime
    yield @@client
  end

  def self.client= client
    @@client = client
  end
end
