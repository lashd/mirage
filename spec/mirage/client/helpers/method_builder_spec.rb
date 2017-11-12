require 'spec_helper'

describe Helpers::MethodBuilder do

  describe 'a builder method' do
    let :model do
      model_class = Class.new do
        extend Helpers::MethodBuilder

        builder_method :name
      end
      model_class.new
    end

    context 'parameter is nil' do
      it 'should set the value to nil' do
        model.name(:joe)
        model.name(nil)
        expect(model.name).to be_nil
      end
    end

    it 'should set a value' do
      model.name(:joe)
      expect(model.name).to eq(:joe)
    end

    it 'should chain' do
      expect(model.name(:joe)).to eq(model)
    end

    it 'should work with booleans' do
      model.name(false)
      expect(model.name).to eq(false)
    end
  end


  it 'should let you define more than one builder method at a time' do
    model_class = Class.new do
      extend Helpers::MethodBuilder
      builder_methods :foo, :bar
    end
    model = model_class.new
    expect(model.respond_to?(:foo)).to be_truthy
    expect(model.respond_to?(:bar)).to be_truthy
  end
end