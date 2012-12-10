require 'spec_helper'
require 'json'
require 'base64'

describe "Mirage Server" do
  include_context :rack_test, :disable_sinatra_error_handling => true

  describe "when adding responses" do
    it 'should accept parameter requirements' do
      required_parameter = {'name' => 'leon'}

      Mirage::MockResponse.should_receive(:new) do |name, response, details|
        details[:required_parameters].should == required_parameter
        mock(:response_id => 1)
      end

      put('/mirage/templates/greeting', {:request => {:parameters => required_parameter}}.to_json)
    end

    it 'should accept required body content' do
      required_body_content = %w(leon)

      Mirage::MockResponse.should_receive(:new) do |name, response, details|
        details[:required_body_content].should == required_body_content
        mock(:response_id => 1)
      end

      put('/mirage/templates/greeting', {:request => {:body_content => required_body_content}}.to_json)
    end


    it 'should set the required delay to be used before responding to a request' do
      required_delay = 0.3
      Mirage::MockResponse.should_receive(:new) do |name, response, details|
        details[:delay].should == required_delay
        mock(:response_id => 1)
      end
      put('/mirage/templates/greeting', {:response => {:delay => required_delay}}.to_json)
    end

    it 'should set the content_type to return' do
      content_type = "text/xml"
      Mirage::MockResponse.should_receive(:new) do |name, response, details|
        details[:content_type].should == content_type
        mock(:response_id => 1)
      end
      put('/mirage/templates/greeting', {:response => {:content_type => content_type}}.to_json)
    end

    it 'should set the http status to return' do
      http_status = 401
      Mirage::MockResponse.should_receive(:new) do |name, response, details|
        details[:status].should == http_status
        mock(:response_id => 1)
      end
      put('/mirage/templates/greeting', {:response => {:status => http_status}}.to_json)
    end

    it 'should set the http method to respond to' do
      method = 'post'
      Mirage::MockResponse.should_receive(:new) do |name, response, details|
        details[:http_method].should == method
        mock(:response_id => 1)
      end
      put('/mirage/templates/greeting', {:response => {:method => method}}.to_json)
    end

    describe 'response body' do
      it 'should be base64 encoded' do
        response_body = "a response"

        Mirage::MockResponse.should_receive(:new) do |name, response, details|
          response.should == response_body
          mock(:response_id => 1)
        end

        put('/mirage/templates/greeting', {:response => {:body => Base64.encode64(response_body)}}.to_json)
      end

      it 'should be recognised when the body has binary content in it' do
        response_body = "binary"
        application_expectations do |app|
          app.should_receive(:contains_binary_data?).with(response_body).and_return(true)
        end

        Mirage::MockResponse.should_receive(:new) do |name, response, details|
          details[:binary].should == true
          mock(:response_id => 1)
        end

        put('/mirage/templates/greeting', {:response => {:body => Base64.encode64(response_body)}}.to_json)
      end

    end


  end


  it 'should return the default response if a specific match is not found' do
    Mirage::MockResponse.should_receive(:find_default).with("", "post", "greeting", {}).and_return(Mirage::MockResponse.new("greeting", "hello", {}))

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
      it 'should let you check the content of a template' do
        response_body = "hello"
        response_id = put('/mirage/templates/greeting', {:response => {:body => Base64.encode64(response_body)}}.to_json).body
        template = JSON.parse(get("/mirage/templates/#{response_id}").body)
        template.should == JSON.parse({:default => false,
                                       :body => Base64.encode64(response_body),
                                       :delay => 0,
                                       :content_type => "text/plain",
                                       :status => 200,
                                       :method => 'get'}.to_json)
      end
    end

    describe 'checking' do

    end


    it 'should delete a template' do
      response_id = put('/mirage/templates/greeting', {:response => {:body => Base64.encode64("hello")}}.to_json).body
      delete("/mirage/templates/#{response_id}")
      expect { get("/mirage/templates/#{response_id}") }.to raise_error(Mirage::ServerResponseNotFound)
    end
  end
end
