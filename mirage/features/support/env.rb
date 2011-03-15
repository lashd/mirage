$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../../lib")
require 'rubygems'
require 'bundler/setup'
Bundler.setup(:test)

require 'mirage'
require 'cucumber'
require 'rspec'

require 'mechanize'


module Web
  include Mirage::Web
  def get(url)
    browser = Mechanize.new
    browser.keep_alive= false
    browser.get(url)
  end

  def hit_mirage(url, parameters={})
    start_time = Time.now
    response = (parameters.include?(:file) ? http_post(url, parameters) : http_get(url, parameters))
    @response_time = Time.now - start_time
    response
  end

  def normalise text
    text.gsub(/[\n]/, ' ').gsub(/\s+/, ' ')
  end
end


module Regression
  def stop_mirage options ={}
    `export RUBYOPT='' && mirage stop`
  end

  def start_mirage options={}
    $mirage = Mirage::Client.new
    `export RUBYOPT='' && mirage start`
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
