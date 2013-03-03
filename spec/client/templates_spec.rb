require 'spec_helper'
require 'mirage/client'
include Mirage

describe 'templates' do

  describe 'deleting' do
    it 'should delete all templates and associated request data' do
      base_url = "base_url"
      Templates.should_receive(:delete).with(base_url)
      Requests.should_receive(:delete_all)

      Templates.new(base_url).delete_all
    end
  end

  describe 'putting templates' do

    endpoint = "greeting"
    value = "hello"

    before :each do
      @base_url = "base_url"
      @template_mock = mock('template')
      Template.should_receive(:new).with("#{@base_url}/#{endpoint}", value).and_return(@template_mock)
      @template_mock.should_receive(:create)
    end

    it 'should create a template' do
      Templates.new(@base_url).put(endpoint, value)
    end

    it 'should accept a block to allow the template to be customised' do
      block_called = false
      Templates.new(@base_url).put(endpoint, value) do |template|
        block_called = true
        template.should == @template_mock
      end
      block_called.should == true
    end
  end
end