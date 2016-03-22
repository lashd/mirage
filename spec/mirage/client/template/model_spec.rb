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
      test_class.is_a?(Helpers::MethodBuilder).should == true
      test_class.is_a?(Template::Model::CommonMethods).should == true
    end

    it 'should include Instance methods' do
      test_class.is_a?(Template::Model::CommonMethods).should == true
    end

    context 'inherited constructor' do
      it 'should set the endpoint of the class' do
        test_class.new.endpoint.should == 'endpoint'
      end

      it 'calls to super should not fail if a constructor has been defined that takes args' do
        test_class.class_eval do
          def initialize arg
            super
          end
        end
        test_class.new('arg').endpoint.should == endpoint

      end
    end

  end

  context 'instances' do
    it 'should have instance methods included' do
      test_class.ancestors.should include(Template::Model::InstanceMethods)
    end


    it 'should include httparty' do
      test_class.ancestors.should include(HTTParty)
    end

    describe 'defaults' do

      it 'should be default the endpoint' do
        endpoint = 'endpoint'
        test_class.endpoint endpoint
        test_class.new.endpoint.should == endpoint
      end

      it 'should be default the status' do
        status = 404
        test_class.status status
        test_class.new.status.should == status
      end

      it 'should be default the content-type' do
        content_type = 'application/json'
        test_class.content_type content_type
        test_class.new.content_type.should == content_type
      end

      it 'should be default the http_method' do
        method = :post
        test_class.http_method method
        test_class.new.http_method.should == method
      end

      it 'should be default the default status' do
        default = true
        test_class.default default
        test_class.new.default.should == default
      end

      it 'should be default the required parameters' do
        required_parameters = {name: 'joe'}
        test_class.required_parameters required_parameters
        test_class.new.required_parameters.should == required_parameters
      end

      it 'should be default the required headers' do
        headers = {name: 'joe'}
        test_class.required_headers headers
        test_class.new.required_headers.should == headers
      end

      it 'should be default the required body content' do
        content = ['content']
        test_class.required_body_content content
        test_class.new.required_body_content.should == content
      end

      it 'should be default the headers' do
        headers = {name: 'joe'}
        test_class.headers headers
        test_class.new.headers.should == headers
      end

      it 'should be default the delay' do
        delay = 4
        test_class.delay delay
        test_class.new.delay.should == delay
      end
    end

  end

end