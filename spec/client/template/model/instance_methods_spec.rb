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
      instance.endpoint.should == endpoint
    end

    it 'requires an endpoint and value to be provided' do
      endpoint, value = 'endpoint', 'value'
      instance = model.new endpoint, value
      instance.endpoint.should == endpoint
      instance.body.should == value
    end

    it 'can use configuration for all http related config' do
      config = Mirage::Template::Configuration.new
      config.content_type 'content_type'
      config.http_method 'method'
      config.status 'status'
      config.default true

      instance = model.new 'endpoint', 'value', config
      instance.content_type.should == config.content_type
      instance.http_method.should == config.http_method
      instance.status.should == config.status
      instance.default.should == config.default

      instance = model.new 'endpoint', config
      instance.content_type.should == config.content_type
      instance.http_method.should == config.http_method
      instance.status.should == config.status
      instance.default.should == config.default
    end
  end

  context 'to_json' do
    describe 'response body' do
      it 'should base64 encode response values' do
        value = "value"
        response = model.new "endpoint", value
        JSON.parse(response.to_json)["response"]["body"].should == Base64.encode64(value)
      end
    end

    describe 'required request parameters' do

      it 'should contain expected request parameters' do
        required_parameters = {:key => "value"}
        instance.required_parameters required_parameters
        JSON.parse(instance.to_json)["request"]["parameters"].should == convert_keys_to_strings(required_parameters)
      end

      it 'should encode parameter requirements that are regexs' do
        instance.required_parameters({:key => /regex/})
        JSON.parse(instance.to_json)["request"]["parameters"].should == convert_keys_to_strings({:key => "%r{regex}"})
      end
    end

    describe 'required body content' do
      it 'should contain expected body content' do
        required_body_content = ["body content"]
        instance.required_body_content required_body_content
        JSON.parse(instance.to_json)["request"]["body_content"].should == required_body_content
      end

      it 'should encode body content requirements that are regexs' do
        instance.required_body_content [/regex/]
        JSON.parse(instance.to_json)["request"]["body_content"].should == %w(%r{regex})
      end
    end

    describe 'required headers' do
      it 'should contain expected headers' do
        required_headers = {:header => "value"}
        instance.required_headers required_headers
        JSON.parse(instance.to_json)["request"]["headers"].should == convert_keys_to_strings(required_headers)
      end

      it 'should encode header requirements that are regexs' do
        instance.required_headers({:header => /regex/})
        JSON.parse(instance.to_json)["request"]["headers"].should == convert_keys_to_strings(:header => "%r{regex}")
      end
    end

    describe 'delay' do
      it 'should default to 0' do
        JSON.parse(instance.to_json)["response"]["delay"].should == 0
      end

      it 'should set the delay' do
        delay = 5
        instance.delay delay
        JSON.parse(instance.to_json)["response"]["delay"].should == delay
      end
    end

    describe 'status code' do
      it 'should default to 200' do
        JSON.parse(instance.to_json)["response"]["status"].should == 200
      end

      it 'should set the status' do
        status = 404
        instance.status status
        JSON.parse(instance.to_json)["response"]["status"].should == status
      end
    end

    describe 'http method' do
      it 'should default to get' do
        JSON.parse(instance.to_json)["request"]["http_method"].should == "get"
      end

      it 'should set the http method' do
        method = :post
        instance.http_method(method)
        JSON.parse(instance.to_json)["request"]["http_method"].should == "post"
      end
    end

    describe 'response as default' do
      it 'should be false by default' do
        JSON.parse(instance.to_json, symbolize_names: true)[:response][:default].should == false
      end

      it 'should set the default value' do
        default = true
        instance.default(default)
        JSON.parse(instance.to_json)["response"]["default"].should == default
      end
    end

    describe 'content type' do
      it 'should be text/plain by default' do
        JSON.parse(instance.to_json)["response"]["content_type"].should == "text/plain"
      end

      it 'should set the default value' do
        content_type = "application/json"
        instance.content_type content_type
        JSON.parse(instance.to_json)["response"]["content_type"].should == content_type
      end
    end

    it 'should set headers' do
      header, value = 'header', 'value'
      instance.headers[header] = value
      JSON.parse(instance.to_json)["response"]["headers"].should == {header => value}
    end
  end

end