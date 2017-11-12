require 'spec_helper'

describe Requests do
  describe '#delete_all' do
    it 'should delete all request data' do
      base_url = "base_url"
      expect(Requests).to receive(:delete).with("#{base_url}/requests")
      Requests.new("#{base_url}/requests").delete_all
    end
  end

  describe '.get' do
    let(:id) { "url_for_request_entity" }
    let(:request_url) { "requested_url" }
    let(:trigger_url) { "trigger url" }

    let(:body) { "body" }
    let(:parameters) { {"name" => "joe"} }
    let(:headers) { {"header" => "value"} }

    let(:requests_json) do
      [{body: body,
       headers: headers,
       parameters: parameters,
       request_url: trigger_url,
       id: id}]
    end



    # it 'raises error when request is not found' do
    #   Request.should_receive(:backedup_get).and_raise(StandardError)
    #
    #   expect { Request.get(request_url) }.to raise_error(Request::NotReceivedException)
    # end

    it 'retrieves all requests' do
      expect(described_class).to receive(:backedup_get).with(request_url, format: :json).and_return(requests_json)
      request = described_class.get(request_url)[0]
      expect(request.headers).to eq(headers)
      expect(request.body).to eq(body)
      expect(request.request_url).to eq(trigger_url)
      expect(request.parameters).to eq(parameters)
      expect(request.id).to eq(id)
    end
  end
end