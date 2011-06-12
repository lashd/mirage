require 'rubygems'
$0='Mirage Server'
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'sinatra/base'

module Mirage
  class Server < Sinatra::Base
    configure do |config|
      require 'logger'
      enable :logging
      log_file = File.open('mirage.log', 'a')
      log_file.sync=true
      use Rack::CommonLogger, log_file
      config.set :views, File.dirname(__FILE__) + '/views'
      config.set(:show_exception, false)
      config.set(:raise_errors, false)  
    end

    configure(:development) do |config|
      require 'sinatra/reloader'
      register Sinatra::Reloader
      config.also_reload "**/*.rb"
    end
  end
end


require 'mirage/server'

require 'mirage/client'
include Mirage::Util
options = parse_options(ARGV)
Mirage::Server.configure options
Mirage.client = Mirage::Client.new "http://localhost:#{options[:port]}/mirage"
Mirage::Server.run! :port => options[:port], :show_exceptions => false, :logging => true, :server => 'webrick'


