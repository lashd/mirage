require 'spec_helper'
require 'json'
require 'base64'

describe "Mirage Server" do
  include_context :rack_test, :disable_sinatra_error_handling => true

  describe "when adding responses" do
    before :each do
      Mirage::MockResponse.delete_all
      @mock_response = Mirage::MockResponse.new('endpoint','value')
    end
    it 'should accept parameter requirements' do
      required_parameter = {'name' => 'leon'}

      Mirage::MockResponse.should_receive(:new) do |name, spec|
        spec['request']['parameters'].should == required_parameter
        @mock_response
      end

      put('/mirage/templates/greeting', {:request => {:parameters => required_parameter}}.to_json)
    end

    it 'should accept required body content' do
      required_body_content = %w(leon)

      Mirage::MockResponse.should_receive(:new) do |name, spec|
        spec['request']['body_content'].should == required_body_content
        @mock_response
      end

      put('/mirage/templates/greeting', {:request => {:body_content => required_body_content}}.to_json)
    end


    it 'should set the required delay to be used before responding to a request' do
      required_delay = 0.3
      Mirage::MockResponse.should_receive(:new) do |name, spec|
        spec['response']['delay'].should == required_delay
        @mock_response
      end
      put('/mirage/templates/greeting', {:response => {:delay => required_delay}}.to_json)
    end

    it 'should set the content_type to return' do
      content_type = "text/xml"
      Mirage::MockResponse.should_receive(:new) do |name, spec|
        spec['response']['content_type'].should == content_type
        @mock_response
      end
      put('/mirage/templates/greeting', {:response => {:content_type => content_type}}.to_json)
    end

    it 'should set the http status to return' do
      http_status = 401
      Mirage::MockResponse.should_receive(:new) do |name, spec|
        spec['response']['status'].should == http_status
        @mock_response
      end
      put('/mirage/templates/greeting', {:response => {:status => http_status}}.to_json)
    end

    it 'should set the http method to respond to' do
      method = 'post'
      Mirage::MockResponse.should_receive(:new) do |name, spec|
        spec['request']['http_method'].should == method
        @mock_response
      end
      put('/mirage/templates/greeting', {:request => {:http_method => method}}.to_json)
    end

    it 'should set the requests url against the template that is created' do
      method = 'post'
      response_id = 1
      mock_response = mock('response', :response_id => response_id)
      Mirage::MockResponse.should_receive(:new).and_return(@mock_response)
      put('/mirage/templates/greeting', {:request => {:http_method => method}}.to_json)
      @mock_response.requests_url.should == "http://example.org/mirage/requests/#{response_id}"
    end

  end


  it 'should return the default response if a specific match is not found' do
    Mirage::MockResponse.should_receive(:find_default).with("", "post", "greeting", {}).and_return(Mirage::MockResponse.new("greeting", {:response => {:body => "hello"}}))

    response_template = {
        :request => {
            :body_content => %w(leon),
            :content_type => "post"
        },
        :response => {
            :body => "hello leon"
        }
    }
    put('/mirage/templates/greeting', response_template.to_json)
    post('/mirage/responses/greeting')
  end

  describe "operations" do
    describe 'resolving responses' do
      it 'should return the default response' do
        put('/mirage/templates/level1', {:response => {:body => Base64.encode64("level1")}}.to_json)
        put('/mirage/templates/level1/level2', {:response => {:body => Base64.encode64("level2"), :default => true}}.to_json)
        get('/mirage/responses/level1/level2/level3').body.should == "level2"
      end
    end

    describe 'checking templates' do
      it 'should return the descriptor for a template' do
        response_body = "hello"
        response_id = JSON.parse(put('/mirage/templates/greeting', {:response => {:body => Base64.encode64(response_body)}}.to_json).body)['id']
        template = JSON.parse(get("/mirage/templates/#{response_id}").body)
        template.should == JSON.parse({:endpoint => "greeting",
                                       :id => response_id,
                                       :requests_url => "http://example.org/mirage/requests/#{response_id}",
                                       :request => {:parameters => {}, :http_method => "get", :body_content => []},
                                       :response => {:default => false,
                                                     :body => Base64.encode64(response_body),
                                                     :delay => 0,
                                                     :content_type => "text/plain",
                                                     :status => 200}
                                      }.to_json)
      end
    end

    it 'should return tracked request data' do
      response_id = JSON.parse(put('/mirage/templates/greeting', {:request => {:http_method => :post}, :response => {:body => Base64.encode64("hello")}}.to_json).body)['id']


      header "MYHEADER", "my_header_value"
      post("/mirage/responses/greeting?param=value", 'body')
      request_data = JSON.parse(get("/mirage/requests/#{response_id}").body)

      request_data['parameters'].should == {'param' => 'value'}
      request_data['headers']["MYHEADER"].should == "my_header_value"
      request_data['body'].should == "body"
      request_data['request_url'].should == "http://example.org/mirage/requests/#{response_id}"

    end


    it 'should delete a template' do
      response_id = JSON.parse(put('/mirage/templates/greeting', {:response => {:body => Base64.encode64("hello")}}.to_json).body)['id']
      delete("/mirage/templates/#{response_id}")
      expect { get("/mirage/templates/#{response_id}") }.to raise_error(Mirage::ServerResponseNotFound)
    end
  end
end
