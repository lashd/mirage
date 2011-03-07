require 'mirage/client'
require 'mirage/util'
require 'mirage/core'

class Mirage
  def self.default
    yield @@client
  end

  def self.client= client
    @@client = client
  end
end