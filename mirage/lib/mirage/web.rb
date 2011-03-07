class Mirage
  module Web
    class File
      def initialize response
        @response = response
      end

      def save_as path
        @response.save_as(path)
      end
    end

    def http_get url, params={}
      uri = URI.parse(url)
      if params[:body]
        response = Net::HTTP.start(uri.host, uri.port) do |http|
          request = Net::HTTP::Get.new(uri.path)
          request.body=params[:body]
          http.request(request)
        end

        def response.code
          @code.to_i
        end

      else
        response = using_mechanize do |browser|
          browser.get(url, params)
        end
      end

      return response.code == 200 ? response.body : response if response.is_a?(Mechanize::Page) || response.is_a?(Net::HTTPOK)
      return File.new(response) if response.is_a?(Mechanize::File)
      response
    end

    def http_post url, params={}
      response = using_mechanize do |browser|
        browser.post(url, params)
      end
      response.code == 200 ? response.body : response
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
