require 'rubygems'

$0='Mirage Server'
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'sinatra'
require 'sinatra/base'
require 'sinatra/reloader'


module Mirage
  class MirageServer < Sinatra::Base
    configure do
      require 'logger'
      enable :logging
      log_file = File.open('mirage.log', 'a')
      log_file.sync=true
      use Rack::CommonLogger, log_file
      register Sinatra::Reloader
      also_reload "**/*.rb"
    end
  end
end
require 'mirage'
include Mirage::Util
#
options = parse_options(ARGV)


DEFAULT_RESPONSES_DIR = "#{options[:defaults_directory]}"
Mirage.client = Mirage::Client.new
set(:show_exception, false)
set(:raise_errors, true)

Mirage::MirageServer.run! :port => options[:port], :show_exceptions => false, :logging => true, :server => 'webrick'


