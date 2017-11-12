require 'hashie/mash'
module Mirage
  class Request
    attr_accessor :parameters, :headers, :body, :request_url, :id
  end
end