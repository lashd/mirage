require 'spec_helper'

describe Template::Model::InstanceMethods do


  let!(:model) do
    Class.new do
      include Template::Model::InstanceMethods
    end
  end

  let!(:instance) do
    model.new '', ''
  end


  context 'initialize' do

    it 'requires an endpoint' do
      endpoint = 'value'
      instance = model.new endpoint
      expect(instance.endpoint).to eq(endpoint)
    end

    it 'requires an endpoint and value to be provided' do
      endpoint, value = 'endpoint', 'value'
      instance = model.new endpoint, value
      expect(instance.endpoint).to eq(endpoint)
      expect(instance.body).to eq(value)
    end

    it 'can use configuration for all http related config' do
      config = Mirage::Template::Configuration.new
      config.content_type 'content_type'
      config.http_method 'method'
      config.status 'status'
      config.default true

      instance = model.new 'endpoint', 'value', config
      expect(instance.content_type).to eq(config.content_type)
      expect(instance.http_method).to eq(config.http_method)
      expect(instance.status).to eq(config.status)
      expect(instance.default).to eq(config.default)

      instance = model.new 'endpoint', config
      expect(instance.content_type).to eq(config.content_type)
      expect(instance.http_method).to eq(config.http_method)
      expect(instance.status).to eq(config.status)
      expect(instance.default).to eq(config.default)
    end
  end

  context 'to_json' do
    describe 'response body' do
      it 'should base64 encode response values' do
        value = "value"
        response = model.new "endpoint", value
        expect(JSON.parse(response.to_json)["response"]["body"]).to eq(Base64.encode64(value))
      end
    end

    describe 'required request parameters' do

      it 'should contain expected request parameters' do
        required_parameters = {:key => "value"}
        instance.required_parameters required_parameters
        expect(JSON.parse(instance.to_json)["request"]["parameters"]).to eq(convert_keys_to_strings(required_parameters))
      end

      it 'should encode parameter requirements that are regexs' do
        instance.required_parameters({:key => /regex/})
        expect(JSON.parse(instance.to_json)["request"]["parameters"]).to eq(convert_keys_to_strings({:key => "%r{regex}"}))
      end
    end

    describe 'required body content' do
      it 'should contain expected body content' do
        required_body_content = ["body content"]
        instance.required_body_content required_body_content
        expect(JSON.parse(instance.to_json)["request"]["body_content"]).to eq(required_body_content)
      end

      it 'should encode body content requirements that are regexs' do
        instance.required_body_content [/regex/]
        expect(JSON.parse(instance.to_json)["request"]["body_content"]).to eq(%w(%r{regex}))
      end
    end

    describe 'required headers' do
      it 'should contain expected headers' do
        required_headers = {:header => "value"}
        instance.required_headers required_headers
        expect(JSON.parse(instance.to_json)["request"]["headers"]).to eq(convert_keys_to_strings(required_headers))
      end

      it 'should encode header requirements that are regexs' do
        instance.required_headers({:header => /regex/})
        expect(JSON.parse(instance.to_json)["request"]["headers"]).to eq(convert_keys_to_strings(:header => "%r{regex}"))
      end
    end

    describe 'delay' do
      it 'should default to 0' do
        expect(JSON.parse(instance.to_json)["response"]["delay"]).to eq(0)
      end

      it 'should set the delay' do
        delay = 5
        instance.delay delay
        expect(JSON.parse(instance.to_json)["response"]["delay"]).to eq(delay)
      end
    end

    describe 'status code' do
      it 'should default to 200' do
        expect(JSON.parse(instance.to_json)["response"]["status"]).to eq(200)
      end

      it 'should set the status' do
        status = 404
        instance.status status
        expect(JSON.parse(instance.to_json)["response"]["status"]).to eq(status)
      end
    end

    describe 'http method' do
      it 'should default to get' do
        expect(JSON.parse(instance.to_json)["request"]["http_method"]).to eq("get")
      end

      it 'should set the http method' do
        method = :post
        instance.http_method(method)
        expect(JSON.parse(instance.to_json)["request"]["http_method"]).to eq("post")
      end
    end

    describe 'response as default' do
      it 'should be false by default' do
        expect(JSON.parse(instance.to_json, symbolize_names: true)[:response][:default]).to eq(false)
      end

      it 'should set the default value' do
        default = true
        instance.default(default)
        expect(JSON.parse(instance.to_json)["response"]["default"]).to eq(default)
      end
    end

    describe 'content type' do
      it 'should be text/plain by default' do
        expect(JSON.parse(instance.to_json)["response"]["content_type"]).to eq("text/plain")
      end

      it 'should set the default value' do
        content_type = "application/json"
        instance.content_type content_type
        expect(JSON.parse(instance.to_json)["response"]["content_type"]).to eq(content_type)
      end
    end

    it 'should set headers' do
      header, value = 'header', 'value'
      instance.headers[header] = value
      expect(JSON.parse(instance.to_json)["response"]["headers"]).to eq({header => value})
    end
  end

end