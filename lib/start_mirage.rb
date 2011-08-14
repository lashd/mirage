require 'rubygems'
$0='Mirage Server'
ROOT_DIR = File.dirname(__FILE__)
$LOAD_PATH.unshift(ROOT_DIR)

require 'sinatra'
require 'mirage/server'
require 'mirage/client'

include Mirage::Util

module Mirage
  class Server < Sinatra::Base
    
    configure do
      options = parse_options(ARGV)
      set :defaults_directory, options[:defaults_directory]
      set :port, options[:port]
      set :show_exceptions, false
      set :logging, true
      set :server, 'webrick'
      set :views, "#{ROOT_DIR}/views"

      log_file = File.open('mirage.log', 'a')
      log_file.sync=true
      use Rack::CommonLogger, log_file
      enable :logging
    end
  end
end

Mirage::Server.run! 


