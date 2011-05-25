require 'rubygems'

$0='Mirage Server'
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'mirage'
include Mirage::Util
#
options = parse_options(ARGV)
require 'sinatra'

DEFAULT_RESPONSES_DIR = "#{options[:defaults_directory]}"
Mirage.client = Mirage::Client.new
set(:show_exception, false)
set(:raise_errors, true)

Mirage::MirageServer.run! :port => options[:port], :show_exceptions => false, :logging => true, :server => 'webrick'


