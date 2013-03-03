module Mirage
  module Request
    include HTTParty
    base_uri "http://localhost:7001/mirage/requests"
  end
end