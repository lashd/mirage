require 'rubygems'

$0='Mirage Server'
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'sinatra'
require 'sinatra/base'

require 'mirage/util'
include Mirage::Util
options = parse_options(ARGV)

$debug = options[:debug]

module Mirage
  class MirageServer < Sinatra::Base
    configure do
      require 'logger'
      enable :logging
      log_file = File.open('mirage.log', 'a')
      log_file.sync=true
      use Rack::CommonLogger, log_file

      if $debug
        require 'sinatra/reloader'
        register Sinatra::Reloader
        also_reload "**/*.rb"
      end
      set :views, File.dirname(__FILE__) + '/views'
    end
  end
end


require 'mirage'


DEFAULT_RESPONSES_DIR = "#{options[:defaults_directory]}"
Mirage.client = Mirage::Client.new
set(:show_exception, false)
set(:raise_errors, true)

Mirage::MirageServer.run! :port => options[:port], :show_exceptions => false, :logging => true, :server => 'webrick'


