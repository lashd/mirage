module Mirage
  module Web
    class FileResponse
      def initialize response
        @response = response
      end

      def save_as path
        @response.save_as(path)
      end
    end

    def http_get url, params={}
      using_mechanize do |browser|
        params[:body] ? browser.put(url, params[:body]) : browser.get(url, params)  
      end
    end

    def http_post url, params={}
      using_mechanize do |browser|
        browser.post(url, params)
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
end
