require 'spec_helper'
require 'mirage/client'


describe Mirage::Template do

  describe 'get' do
    it 'should load a template given its id' do
      endpoint = "endpoint"
      id = 1
      requests_url = 'request_url'
      value = "Hello"
      default = false
      delay = 1.2
      content_type = "application/json"
      status = 201
      headers = {'header' => 'value'}


      required_parameters = {"name" => 'joe'}
      required_body_content = %{content}
      required_headers = {"header" => 'value'}
      http_method = "get"

      template_json = {
          endpoint: endpoint,
          id: id,
          requests_url: requests_url,
          response:{
              default: default,
              body: value,
              delay: delay,
              content_type: content_type,
              status: status,
              headers: headers
          },
          request: {
              parameters: required_parameters,
              body_content: required_body_content,
              headers: required_headers,
              http_method: http_method
          }
      }

      template_url = "url"
      Template.should_receive(:backedup_get).with(template_url, :format => :json).and_return(template_json)

      template = Template.get(template_url)
      template.value.should == value
      template.endpoint.should == endpoint
      template.id.should == id

      template.default.should == default
      template.default.should == default
      template.delay.should == delay
      template.content_type.should == content_type
      template.status.should == status
      template.headers.should == headers

      template.required_parameters.should  == required_parameters
      template.required_body_content.should == required_body_content
      template.required_headers.should  == required_headers
      template.http_method.should == http_method
      template.url.should  == template_url
      template.requests_url.should == requests_url
    end
  end


  describe 'creating' do
    json = "reponse json"
    endpoint = "greeting"

    it 'should create a template on mirage' do
      template = Template.new(endpoint,json)

      template.should_receive(:to_json).and_return(json)
      Template.should_receive(:put).with(endpoint, :body => json, :headers => {'content-type' => 'application/json'}).and_return(convert_keys_to_strings({:id => 1}))
      template.create
      template.id.should == 1
    end

    it 'should have default values set' do
      template = Template.new(endpoint,json)
      template.http_method.should == :get
      template.status.should == 200
      template.content_type.should == "text/plain"
      template.default.should == false
      template.delay.should == 0
    end
  end


  describe 'deleting' do

    it 'should clear a response' do
      id = 1
      template_url = "base_url/templates/#{id}"
      request_url = "base_url/requests/#{id}"

      template = Template.new("", "")
      template.url = template_url
      template.requests_url = request_url


      template.stub(:id).and_return(id)

      Template.should_receive(:delete).with(template_url)

      Mirage::Request.should_receive(:delete).with(request_url)
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

    it 'should set headers' do
      header, value = 'header', 'value'
      template = Template.new 'endpoint', value
      template.headers[header] = value
      JSON.parse(template.to_json)["response"]["headers"].should == {header => value}
    end

  end
end
