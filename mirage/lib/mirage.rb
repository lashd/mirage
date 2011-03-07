require 'mirage/web'
require 'mirage/util'
require 'mirage/core'
require 'mirage/client'

class Mirage
  def self.default
    yield @@client
  end

  def self.client= client
    @@client = client
  end
end
