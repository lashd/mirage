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

module Web
  def get(url)
    browser = Mechanize.new
    browser.keep_alive= false
    browser.get(url)
  end
end


module Regression
  def stop_mirage options ={}
    `export RUBYOPT='' && mirage stop`
  end

  def start_mirage options={}
    args = ''

    args << "-p #{options[:port]}" if options[:port]
    $mirage = Mirage::Client.new(options)

    `export RUBYOPT='' && mirage start #{args}`
  end
end

module IntelliJ
  include Mirage::Util

  def stop_mirage
    system "#{File.dirname(__FILE__)}/../../bin/mirage stop"
    wait_until do
      !$mirage.running?
    end
    FileUtils.rm_rf('tmp')
  end

  def start_mirage
    puts "starting mirage"
    $mirage = Mirage::Client.new
    system "#{File.dirname(__FILE__)}/../../bin/mirage start"

    wait_until do
      $mirage.running?
    end
  end
end

'regression' == ENV['mode'] ? World(Regression) : World(IntelliJ)
'regression' == ENV['mode'] ? include(Regression) : include(IntelliJ)
World(Web)
start_mirage

at_exit do
  stop_mirage
end
