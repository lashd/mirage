module Mirage
  class Server < Sinatra::Base
    REQUESTS = {}
    delete '/requests' do
      synchronize do
        REQUESTS.clear
      end

      200
    end

    delete '/requests/:id' do
      synchronize do
        REQUESTS.delete(response_id)
      end

      200
    end

    get '/requests/:id' do
      content_type :json
      tracked_requests = tracked_requests(response_id)
      response = []
      if tracked_requests
        tracked_requests.collect do |tracked_request|
          tracked_request.body.rewind
          body = tracked_request.body.read

          parameters = tracked_request.params.dup.select { |key, value| key != body }

          response << {id: request.url,
           request_url: tracked_request.url,
           headers: extract_http_headers(tracked_request.env),
           parameters: parameters,
           body: body}
        end
        response.to_json
      else
        404
      end
    end
  end
end