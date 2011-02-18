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

      begin
        response = Mechanize.new.get("#{MOCKSERVER_URL}#{url}", params)
        def response.code
          @code.to_i
        end
      rescue Exception => e
        response = e
        def response.code
          self.response_code.to_i
        end
      end

    end

    response
  end
end
