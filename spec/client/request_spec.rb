require 'spec_helper'

describe Request do
  let(:request_url) { "url" }
  let(:trigger_url) { "trigger url" }

  let(:body) { "body" }
  let(:parameters) { {"name" => "joe"} }
  let(:headers) { {"header" => "value"} }

  let(:request_json) do
    {body: body,
     headers: headers,
     parameters: parameters,
     request_url: trigger_url}
  end

  it 'delete a request' do
    request_url = "url"
    Request.should_receive(:delete).with(request_url)
    request = Request.new
    request.request_url = request_url
    request.delete
  end

  it 'should load request data' do
    Request.should_receive(:backedup_get).with(request_url, format: :json).and_return(request_json)

    request = Request.get(request_url)
    request.headers.should == headers
    request.body.should == body
    request.request_url.should == trigger_url
    request.parameters.should == parameters
  end

end