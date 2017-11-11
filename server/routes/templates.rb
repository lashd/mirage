module Mirage
  class Server < Sinatra::Base
    get '/templates/:id/preview' do
      send_response(MockResponse.find_by_id(response_id), '', {}, '')
    end

    delete '/templates/:id' do
      synchronize do
        MockResponse.delete(response_id)
        REQUESTS.delete(response_id)
      end

      200
    end

    put '/templates/*' do |name|
      content_type :json
      mock_response = synchronize do
        MockResponse.new(name, JSON.parse(request.body.read))
      end

      mock_response.requests_url = request.url.gsub("/templates/#{name}", "/requests/#{mock_response.response_id}")
      {:id => mock_response.response_id}.to_json
    end


    delete '/templates' do
      synchronize do
        REQUESTS.clear
        MockResponse.delete_all
      end

      200
    end

    get '/templates/:id' do
      MockResponse.find_by_id(response_id).raw
    end

  end
end