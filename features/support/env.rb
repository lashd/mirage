$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../../lib")
require 'rubygems'
require 'bundler/setup'
Bundler.setup(:test)
require 'mirage'
require 'cucumber'
require 'rspec'
require 'mechanize'

SCRATCH = './scratch'
RUBY_CMD = RUBY_PLATFORM == 'JAVA' ? 'jruby' : 'ruby'


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
  def stop_mirage
    `export RUBYOPT='' && cd #{SCRATCH} && mirage stop`
  end

  def start_mirage
    `truncate mirage.log --size 0`
    `export RUBYOPT='' && cd #{SCRATCH} && mirage start`
  end
end

module IntelliJ
  include Mirage::Util

  def stop_mirage
    system "cd #{SCRATCH} && ../bin/mirage stop"
    wait_until do
      !$mirage.running?
    end
  end

  def start_mirage
    puts "starting mirage"
    `truncate mirage.log --size 0`
    system "cd #{SCRATCH} && ../bin/mirage start"

    wait_until do
      $mirage.running?
    end
  end
end

'regression' == ENV['mode'] ? World(Regression) : World(IntelliJ)
'regression' == ENV['mode'] ? include(Regression) : include(IntelliJ)

World(Web)

Before do
  FileUtils.mkdir_p(SCRATCH)
  $mirage = Mirage::Client.new

  if $mirage.running?
    $mirage.clear
  else
    start_mirage
  end
  
  `ls #{SCRATCH}/ | grep -v mirage.log | rm -rf`
  'regression' == ENV['mode'] ? `truncate -s 0 mirage.log` : `truncate -s 0 #{SCRATCH}/mirage.log`
  $mirage = Mirage::Client.new


end

at_exit do
  stop_mirage
end
