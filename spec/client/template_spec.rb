require 'spec_helper'
require 'mirage/client'


describe Mirage::Template do
  include Mirage

  describe 'loading' do
    it 'should retreive template definition from mirage' do
      response_id = 1
      Template.should_receive(:get) do |url|
        url.should == "/#{response_id}"
      end
      Template.find(response_id)
    end
  end

  describe 'creating' do
    it 'should create a template on mirage' do
      json = "reponse json"
      endpoint = "greeting"
      template = Template.new(endpoint,json)

      template.should_receive(:to_json).and_return(json)
      Template.should_receive(:put).with("/#{endpoint}", :body => json,:headers => {"Content-Type" => "application/json"})
      template.create
    end
  end

  describe 'deleting' do

    it 'should clear a response' do
      id = 1
      template = Template.new("", "")
      template.stub(:id).and_return(id)

      Template.should_receive(:delete).with("/#{id}")
      Request.should_receive(:delete).with("/#{id}")
      template.delete
    end

  end

  describe "json representation" do

    describe 'response body' do
      it 'should base64 encode response values' do
        response = Template.new "endpoint", "value"
        JSON.parse(response.to_json)["response"]["body"].should == Base64.encode64("value")
      end
    end

    describe 'required request parameters' do
      it 'should contain expected request parameters' do
        response = Template.new "endpoint", "value"
        required_parameters = {:key => "value"}
        response.required_parameters = required_parameters
        JSON.parse(response.to_json)["request"]["parameters"].should == convert_keys_to_strings(required_parameters)
      end

      it 'should encode parameter requirements that are regexs' do
        response = Template.new "endpoint", "value"
        response.required_parameters = {:key => /regex/}
        JSON.parse(response.to_json)["request"]["parameters"].should == convert_keys_to_strings({:key => "%r{regex}"})
      end
    end

    describe 'required body content' do
      it 'should contain expected body content' do
        response = Template.new "endpoint", "value"
        required_body_content = ["body content"]
        response.required_body_content = required_body_content
        JSON.parse(response.to_json)["request"]["body_content"].should == required_body_content
      end

      it 'should encode body content requirements that are regexs' do
        response = Template.new "endpoint", "value"
        response.required_body_content = [/regex/]
        JSON.parse(response.to_json)["request"]["body_content"].should == %w(%r{regex})
      end
    end

    describe 'required headers' do
      it 'should contain expected headers' do
        response = Template.new "endpoint", "value"
        required_headers = {:header => "value"}
        response.required_headers = required_headers
        JSON.parse(response.to_json)["request"]["headers"].should == convert_keys_to_strings(required_headers)
      end

      it 'should encode header requirements that are regexs' do
        response = Template.new "endpoint", "value"
        response.required_headers = {:header => /regex/}
        JSON.parse(response.to_json)["request"]["headers"].should == convert_keys_to_strings(:header => "%r{regex}")
      end
    end

    describe 'delay' do
      it 'should default to 0' do
        response = Template.new "endpoint", "value"
        JSON.parse(response.to_json)["delay"].should == 0
      end

      it 'should set the delay' do
        delay = 5
        response = Template.new "endpoint", "value"
        response.delay = delay
        JSON.parse(response.to_json)["delay"].should == delay
      end
    end

    describe 'status code' do
      it 'should default to 200' do
        response = Template.new "endpoint", "value"
        JSON.parse(response.to_json)["response"]["status"].should == 200
      end

      it 'should set the status' do
        status = 404
        response = Template.new "endpoint", "value"
        response.status = status
        JSON.parse(response.to_json)["response"]["status"].should == status
      end
    end

    describe 'http method' do
      it 'should default to get' do
        response = Template.new "endpoint", "value"
        JSON.parse(response.to_json)["request"]["http_method"].should == "get"
      end

      it 'should set the http method' do
        method = :post
        response = Template.new "endpoint", "value"
        response.http_method = method
        JSON.parse(response.to_json)["request"]["http_method"].should == "post"
      end
    end

    describe 'response as default' do
      it 'should be false by default' do
        response = Template.new "endpoint", "value"
        JSON.parse(response.to_json)["response"]["default"].should == false
      end

      it 'should set the default value' do
        default = true
        response = Template.new "endpoint", "value"
        response.default = default
        JSON.parse(response.to_json)["response"]["default"].should == default
      end
    end

    describe 'content type' do
      it 'should be text/plain by default' do
        response = Template.new "endpoint", "value"
        JSON.parse(response.to_json)["response"]["content_type"].should == "text/plain"
      end

      it 'should set the default value' do
        content_type = "application/json"
        response = Template.new "endpoint", "value"
        response.content_type = content_type
        JSON.parse(response.to_json)["response"]["content_type"].should == content_type
      end
    end

  end
end
