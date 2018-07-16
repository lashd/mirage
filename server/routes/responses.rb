module Mirage
  class Server < Sinatra::Base
    # TODO write tests to check that all of these verbs are supported
    %w(get post delete put options head patch).each do |http_method|
      send(http_method, '/responses/*') do |name|
        body, query_string = request.body.read.to_s, request.query_string
        name = "/#{name}"

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
          tracked_requests(record.response_id) << request.dup
        end


        send_response(record, body, request, query_string)
      end
    end
  end
end