$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../../lib")
require 'rubygems'
require 'bundler/setup'
Bundler.setup(:test)

require 'mirage'
require 'cucumber'
require 'rspec'

require 'mechanize'
MOCKSERVER_URL = "http://localhost:7001"

$mirage = Mirage::Client.new


module Regression
  def stop_mockserver options ={}
  end

  def start_mockserver options={}
  end
end

module IntelliJ
  include  Mirage::Util

  def stop_mockserver options={}
    system "#{File.dirname(__FILE__)}/../../bin/mirage stop"
    wait_until do
      !$mirage.running?
    end
    FileUtils.rm_rf('tmp')
  end

  def start_mockserver options ={}
    stop_mockserver
    puts "Starting mockserver intellij style  #{File.dirname(__FILE__)}/../../bin/mirage start"

    system "#{File.dirname(__FILE__)}/../../bin/mirage start"
    wait_until do
      $mirage.running?
    end
  end
end

'regression' == ENV['mode'] ? World(Regression) : World(IntelliJ)
'regression' == ENV['mode'] ? include(Regression) : include(IntelliJ)
start_mockserver

at_exit do
  stop_mockserver
end