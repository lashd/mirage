require 'sinatra'
require 'helpers'
require 'base64'
require 'routes'
require 'errors'
module Mirage
  class Server < Sinatra::Base
    helpers Helpers::TemplateRequirements, Helpers::HttpHeaders
  end
end