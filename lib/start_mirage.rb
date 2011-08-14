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
      
      set :defaults_directory, parse_options(ARGV)[:defaults_directory] 
      require 'logger'
      enable :logging
      log_file = File.open('mirage.log', 'a')
      log_file.sync=true
      use Rack::CommonLogger, log_file
      set :views, "#{ROOT_DIR}/views"
      set :show_exception, false
      set :raise_errors, false  
    end
  end
end

options = parse_options(ARGV)
Mirage.client = Mirage::Client.new "http://localhost:#{options[:port]}/mirage"
Mirage::Server.run! :port => options[:port], :show_exceptions => false, :logging => true, :server => 'webrick'


