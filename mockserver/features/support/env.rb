require 'rubygems'
require 'bundler/setup'
Bundler.setup(:test)
require 'cucumber'
require 'open-uri'
require 'rspec'

require 'mechanize'
MOCKSERVER_URL = "http://localhost:7001"

module Web
  def get_with_whole_url url
    using_mechanize do |browser|
      browser.get(url)
    end
  end
  def get url, params={}
    if params[:body]
      response = Net::HTTP.start("localhost", 7001) do |http|
        request = Net::HTTP::Get.new(url)
        request.body=params[:body]
        http.request(request)
      end

      def response.code
        @code.to_i
      end

    else
      response = using_mechanize do |browser|
        browser.get("#{MOCKSERVER_URL}#{url}", params)
      end

    end

    response
  end

  def post url, params
    using_mechanize do |browser|
      browser.post("#{MOCKSERVER_URL}#{url}", params)
    end
  end

  private
  def using_mechanize
    begin
      browser = Mechanize.new
      browser.keep_alive = false
      response = yield browser

      def response.code
        @code.to_i
      end
    rescue Exception => e
      response = e

      def response.code
        self.response_code.to_i
      end

      def response.body
        ""
      end
    end
    response
  end

end

module Regression
  def stop_mockserver
  end

  def start_mockserver
  end
end

module IntelliJ
  def stop_mockserver
    puts "Stoping mockserver"
    `#{File.dirname(__FILE__)}/../../bin/mirage stop`
    wait_until do
      get('/mirage/clear').is_a?(Errno::ECONNREFUSED)
    end
    FileUtils.rm_rf('tmp')
  end

  def start_mockserver
    stop_mockserver
    puts "Starting mockserver intellij style  #{File.dirname(__FILE__)}/../../bin/mirage start"

    `#{File.dirname(__FILE__)}/../../bin/mirage start`
    wait_until do
      begin
        open('http://localhost:7001/mirage/clear')
      rescue
      end
    end
  end
end
include Web


def wait_until time=30
  start_time = Time.now
  until Time.now >= start_time + time
    sleep 0.1
    return if yield
  end
  raise 'timeout waiting'
end





World(Web)

'regression' == ENV['mode'] ? World(Regression) : World(IntelliJ)
'regression' == ENV['mode'] ? include(Regression) : include(IntelliJ)
start_mockserver

at_exit do
  stop_mockserver
end