require 'spec_helper'
require 'mirage/client'


describe Mirage::Request do

  it 'delete a request' do
    request_url = "url"
    Request.should_receive(:delete).with(request_url)
    request = Request.new
    request.request_url = request_url
    request.delete
  end

  it 'should load request data' do
    request_url = "url"
    trigger_url = "trigger url"

    body = "body"
    parameters = {"name" => "joe"}
    headers = {"header" => "value"}

    request_json = {
        body: body,
        headers: headers,
        parameters: parameters,
        request_url: trigger_url
    }

    Request.should_receive(:backedup_get).with(request_url,format: :json).and_return(request_json)

    request = Request.get(request_url)
    request.headers.should == headers
    request.body.should == body
    request.request_url.should == trigger_url
    request.parameters.should == parameters
  end

end