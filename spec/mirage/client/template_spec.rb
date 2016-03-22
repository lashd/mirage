require 'spec_helper'
require 'mirage/client'


describe Mirage::Template do

  describe 'get' do
    it 'should load a template given its id' do
      endpoint = "endpoint"
      id = 1
      requests_url = 'request_url'
      body = "Hello"
      default = true
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
              body: Base64.encode64(body),
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
      template_json.should_receive(:code).and_return 200

      template_url = "url"
      Template.should_receive(:backedup_get).with(template_url, :format => :json).and_return(template_json)

      template = Template.get(template_url)
      template.body.should == body
      template.endpoint.should == endpoint
      template.id.should == id

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

    it 'should raise an error if the template is not found' do
      template_url = 'url'
      response = double(code: 404)
      Template.should_receive(:backedup_get).with(template_url, :format => :json).and_return response
      expect{Template.get(template_url)}.to raise_error Mirage::TemplateNotFound
    end
  end

  describe 'initialize' do
    it 'throws and exception if an endpoint is not supplied as the first parameter' do
      expect{Template.new}.to raise_error(ArgumentError)
    end

    it 'throws and exception if first argument is not a string' do
      expect{Template.new(:endpoint)}.to raise_error(ArgumentError)
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
      template.url template_url
      template.requests_url request_url


      template.stub(:id).and_return(id)

      Template.should_receive(:delete).with(template_url)

      Mirage::Request.should_receive(:delete).with(request_url)
      template.delete
    end

  end

  describe 'method missing' do
    it 'should delagate to the caller if it is set' do
      caller = Object.new
      caller.should_receive(:some_method)
      template = Template.new('endpoint')
      template.caller_binding = caller
      template.some_method
    end

    it 'should throw a standard method missing error if a caller binding is not set' do
      expect{Template.new('endpoint').some_method}.to raise_error(NameError)
    end
  end
end
