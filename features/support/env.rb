ROOT_DIR = File.expand_path("#{File.dirname(__FILE__)}/../..")
SOURCE_PATH = "#{ROOT_DIR}/lib"


$LOAD_PATH.unshift(SOURCE_PATH)
require 'rubygems'
require 'mirage/client'
require 'cucumber'
require 'rspec'
require 'mechanize'
require 'childprocess'

SCRATCH = "#{ROOT_DIR}/scratch"
RUBY_CMD = ChildProcess.jruby? ? 'jruby' : 'ruby'
BLANK_RUBYOPT_CMD = ChildProcess.windows? ? 'set RUBYOPT=' : "export RUBYOPT=''"
ENV['RUBYOPT'] = ''


if 'regression' == ENV['mode']
  MIRAGE_CMD = ChildProcess.windows? ? `where mirage.bat`.chomp : 'mirage'
else
  MIRAGE_CMD = "#{RUBY_CMD} ../bin/mirage"
end

World(Mirage::Web)

