module Mirage
  class Server < Sinatra::Base
    %w(get post delete put options).each do |http_method|
      send(http_method, '/responses/*') do |name|
        body, query_string = Rack::Utils.unescape(request.body.read.to_s), request.query_string

        options = {:body => body,
                   :http_method => http_method,
                   :endpoint => name,
                   :params => request.params,
                   :headers => extract_http_headers(env)}
        begin
          record = MockResponse.find(options)
        rescue ServerResponseNotFound
          record = MockResponse.find_default(options)
        end

        synchronize do
          REQUESTS[record.response_id] = request.dup
        end


        send_response(record, body, request, query_string)
      end
    end
  end
end