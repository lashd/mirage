require 'spec_helper'

describe Template::Model do
  let(:endpoint) { 'endpoint' }
  let!(:test_class) do
    Class.new do
      extend Template::Model

      endpoint 'endpoint'

      def initialize
        super
      end
    end
  end
  context 'class' do
    it 'should extend MethodBuilder and CommonMethods' do
      expect(test_class.is_a?(Helpers::MethodBuilder)).to eq(true)
      expect(test_class.is_a?(Template::Model::CommonMethods)).to eq(true)
    end

    it 'should include Instance methods' do
      expect(test_class.is_a?(Template::Model::CommonMethods)).to eq(true)
    end

    context 'inherited constructor' do
      it 'should set the endpoint of the class' do
        expect(test_class.new.endpoint).to eq('endpoint')
      end

      it 'calls to super should not fail if a constructor has been defined that takes args' do
        test_class.class_eval do
          def initialize arg
            super
          end
        end
        expect(test_class.new('arg').endpoint).to eq(endpoint)

      end
    end

  end

  context 'instances' do
    it 'should have instance methods included' do
      expect(test_class.ancestors).to include(Template::Model::InstanceMethods)
    end


    it 'should include httparty' do
      expect(test_class.ancestors).to include(HTTParty)
    end

    describe 'defaults' do

      it 'should be default the endpoint' do
        endpoint = 'endpoint'
        test_class.endpoint endpoint
        expect(test_class.new.endpoint).to eq(endpoint)
      end

      it 'should be default the status' do
        status = 404
        test_class.status status
        expect(test_class.new.status).to eq(status)
      end

      it 'should be default the content-type' do
        content_type = 'application/json'
        test_class.content_type content_type
        expect(test_class.new.content_type).to eq(content_type)
      end

      it 'should be default the http_method' do
        method = :post
        test_class.http_method method
        expect(test_class.new.http_method).to eq(method)
      end

      it 'should be default the default status' do
        default = true
        test_class.default default
        expect(test_class.new.default).to eq(default)
      end

      it 'should be default the required parameters' do
        required_parameters = {name: 'joe'}
        test_class.required_parameters required_parameters
        expect(test_class.new.required_parameters).to eq(required_parameters)
      end

      it 'should be default the required headers' do
        headers = {name: 'joe'}
        test_class.required_headers headers
        expect(test_class.new.required_headers).to eq(headers)
      end

      it 'should be default the required body content' do
        content = ['content']
        test_class.required_body_content content
        expect(test_class.new.required_body_content).to eq(content)
      end

      it 'should be default the headers' do
        headers = {name: 'joe'}
        test_class.headers headers
        expect(test_class.new.headers).to eq(headers)
      end

      it 'should be default the delay' do
        delay = 4
        test_class.delay delay
        expect(test_class.new.delay).to eq(delay)
      end
    end

  end

end