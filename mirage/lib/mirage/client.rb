require 'mechanize'
require 'open-uri'

class Mirage
  class Client
    def initialize options={}
      options = {:host=>'localhost', :port=>7001, :context_root => 'mirage'}.merge(options)
      @host = options[:host]
      @port = options[:port]
      @context_root = options[:context_root]
    end

    def get endpoint, params={}
      http_get("/get/#{endpoint}", params)
    end

    def set endpoint, params={}
      http_post("/set/#{endpoint}", params)
    end

    def peek response_id
      http_get("/peek/#{response_id}")
    end

    def clear thing=nil, endpoint=nil
      if endpoint.nil?
        http_get("/clear")
      else
          if thing.nil?
          http_get("/clear/#{endpoint}")
        else
          http_get("/clear/#{thing}/#{endpoint}")
        end

      end
    end

    def check response_id
      http_get("/check/#{response_id}")
    end

    def snapshot
      http_post("/snapshot")
    end

    def rollback
      http_post("/rollback")
    end

    def running?
      !http_post('/clear').is_a?(Errno::ECONNREFUSED)
    end

    def load_defaults
      clear
      http_post('/load_defaults')
    end


    private
    def http_get endpoint, params={}
      if params[:body]
        response = Net::HTTP.start(@host, @port) do |http|
          request = Net::HTTP::Get.new("/#{@context_root}/#{endpoint}")
          request.body=params[:body]
          http.request(request)
        end

        def response.code
          @code.to_i
        end

      else
        response = using_mechanize do |browser|
          browser.get("http://#{@host}:#{@port}/#{@context_root}/#{endpoint}", params)
        end

      end

      response
    end

    def http_post url, params={}
      using_mechanize do |browser|
        browser.post("http://#{@host}:#{@port}/#{@context_root}/#{url}", params)
      end
    end

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


end