require 'spec_helper'

describe Template::Model do
  let!(:test_class) do
    Class.new do
      extend Template::Model
    end
  end
  context 'class' do
    it 'should extend ClassMethods and MethodBuilder' do
      test_class.is_a?(Template::Model::ClassMethods).should == true
      test_class.is_a?(Helpers::MethodBuilder).should == true
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