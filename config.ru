require 'rubygems'
ROOT_DIR = File.dirname(__FILE__)
$LOAD_PATH.unshift("#{ROOT_DIR}/lib", "#{ROOT_DIR}/server")

require 'sinatra/base'
require 'extensions/object'
require 'app'
require 'extensions/hash'
require 'mirage/client'

module Mirage
  class Server < Sinatra::Base
    configure do
      options = Hash[*ARGV]
      set :defaults, options["defaults"]
      set :port, options["port"]
      $0="Mirage Server port #{settings.port}"
      set :show_exceptions, false
      set :logging, true
      set :dump_errors, true
      set :server, 'webrick'
      set :views, "#{ROOT_DIR}/views"
      set :bind, '0.0.0.0'

      log_file = File.open('mirage.log', 'a')
      log_file.sync=true
      use Rack::CommonLogger, log_file
      enable :logging
    end
  end
end


run Mirage::Server