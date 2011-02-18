require 'cucumber'
require 'open-uri'
require 'rspec'

require 'mechanize'
MOCKSERVER_URL = "http://localhost:7000"

module Web
  def get url, params={}
    if params[:body]
      response = Net::HTTP.start("localhost", 7000) do |http|
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
      browser.post("#{MOCKSERVER_URL}#{url}",params)
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
    end
    response
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

def stop_mockserver
  puts "Stoping mockserver"
  `thin stop`
  wait_until do
    get('/mockserver/clear').is_a?(Errno::ECONNREFUSED)
  end
  FileUtils.rm_rf('tmp')
end

def start_mockserver
  stop_mockserver
  puts "Starting mockserver"
  `thin -p 7000 -l thin.log -D -V -d -R lib/config.ru start`
  wait_until do
    begin
      open('http://localhost:7000/mockserver/clear')
    rescue
    end
  end
end

start_mockserver



World(Web)


at_exit do
  stop_mockserver
end