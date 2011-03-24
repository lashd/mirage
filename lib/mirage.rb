require 'mirage/web'
require 'mirage/util'
require 'mirage/core'
require 'mirage/client'

module Mirage
  def self.prime
    yield @@client
  end

  def self.client= client
    @@client = client
  end
end
