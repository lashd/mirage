require 'spec_helper'
describe '/responses' do
  include_context :rack_test, :disable_sinatra_error_handling => true
  before :each do
    Mirage::MockResponse.delete_all
  end

  describe '/responses/*' do
    it 'records requests' do
      response_id = JSON.parse(put('/templates/greeting', {:request => {:http_method => :post}, :response => {:body => Base64.encode64("hello")}}.to_json).body)['id']

      header "MYHEADER", "my_header_value"
      post("/responses/greeting?param=request1", 'body')
      post("/responses/greeting?param=request2", 'body')
      expect(Mirage::Server::REQUESTS[response_id].size).to eq(2)
      expect(Mirage::Server::REQUESTS[response_id][0].params['param']).to eq('request1')
      expect(Mirage::Server::REQUESTS[response_id][1].params['param']).to eq('request2')
    end

  end
end