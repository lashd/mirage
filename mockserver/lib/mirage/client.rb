require 'mechanize'
require 'open-uri'

class Mirage
  class Client
    def initialize options={}
      options.merge!({:host=>'localhost', :port=>7001, :context_root => 'mirage'})
      @host = options[:host]
      @port = options[:port]
      @context_root = options[:context_root]
    end

    def get endpoint, params={}

    end

    def set endpoint, params={}

    end

    def clear

    end

    def snapshot

    end

    def rollback

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
          browser.get("http://#{@host}/#{@context_root}", params)
        end

      end

      response
    end

    def http_post url, params
      using_mechanize do |browser|
        browser.post("http://#{@host}/#{@context_root}/#{url}", params)
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