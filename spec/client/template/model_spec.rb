require 'spec_helper'

describe Template::Model do
  let(:endpoint){'endpoint'}
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
    it 'should extend ClassMethods and MethodBuilder' do
      test_class.is_a?(Template::Model::ClassMethods).should == true
      test_class.is_a?(Helpers::MethodBuilder).should == true
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

    it 'provides a method for customising the endpoint of all instances' do
      endpoint = 'endpoint'
      test_class.endpoint endpoint
      test_class.new.endpoint.should == endpoint
    end

    describe 'default status' do
      it 'sets the status of instances if set' do
        status = 404
        test_class.status status
        test_class.new.status.should == status
      end

      it 'status of instances retain the global default if status is not set at the class level' do
        test_class.new.status.should == 200
      end

    end
  end

end