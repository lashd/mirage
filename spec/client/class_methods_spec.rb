require 'spec_helper'

describe Template::Model::ClassMethods do
  context 'class methods' do

    it 'should provide a method for setting the endpoint for the class' do
      endpoint = 'endpoint'
      model_class = Class.new do
        extend Template::Model::ClassMethods

        endpoint endpoint
      end

      model_class.endpoint.should == endpoint
    end

  end

end