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
      expect(template_json).to receive(:code).and_return 200

      template_url = "url"
      expect(Template).to receive(:backedup_get).with(template_url, :format => :json).and_return(template_json)

      template = Template.get(template_url)
      expect(template.body).to eq(body)
      expect(template.endpoint).to eq(endpoint)
      expect(template.id).to eq(id)

      expect(template.default).to eq(default)
      expect(template.delay).to eq(delay)
      expect(template.content_type).to eq(content_type)
      expect(template.status).to eq(status)
      expect(template.headers).to eq(headers)

      expect(template.required_parameters).to  eq(required_parameters)
      expect(template.required_body_content).to eq(required_body_content)
      expect(template.required_headers).to  eq(required_headers)
      expect(template.http_method).to eq(http_method)
      expect(template.url).to  eq(template_url)
      expect(template.requests_url).to eq(requests_url)
    end

    it 'should raise an error if the template is not found' do
      template_url = 'url'
      response = double(code: 404)
      expect(Template).to receive(:backedup_get).with(template_url, :format => :json).and_return response
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

      expect(template).to receive(:to_json).and_return(json)
      expect(Template).to receive(:put).with(endpoint, :body => json, :headers => {'content-type' => 'application/json'}).and_return(convert_keys_to_strings({:id => 1}))
      template.create
      expect(template.id).to eq(1)
    end

    it 'should have default values set' do
      template = Template.new(endpoint,json)
      expect(template.http_method).to eq(:get)
      expect(template.status).to eq(200)
      expect(template.content_type).to eq("text/plain")
      expect(template.default).to eq(false)
      expect(template.delay).to eq(0)
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


      allow(template).to receive(:id).and_return(id)

      expect(Template).to receive(:delete).with(template_url)

      expect(Mirage::Requests).to receive(:delete).with(request_url)
      template.delete
    end

  end

  describe 'method missing' do
    it 'should delagate to the caller if it is set' do
      caller = Object.new
      expect(caller).to receive(:some_method)
      template = Template.new('endpoint')
      template.caller_binding = caller
      template.some_method
    end

    it 'should throw a standard method missing error if a caller binding is not set' do
      expect{Template.new('endpoint').some_method}.to raise_error(NameError)
    end
  end
end
