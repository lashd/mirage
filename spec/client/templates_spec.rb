require 'spec_helper'
require 'mirage/client'

describe 'templates' do


  describe 'deleting' do
    it 'should delete all templates and associated request data' do
      base_url = "base_url"
      requests = mock('requests')
      Requests.should_receive(:new).with(base_url).and_return(requests)

      Templates.should_receive(:delete).with("#{base_url}/templates")
      requests.should_receive(:delete_all)

      Templates.new(base_url).delete_all
    end
  end

  describe 'setting default config' do
    it 'should preset configuration for templates' do
      Template.stub(:put).and_return(convert_keys_to_strings({:id => 1}))
      templates = Templates.new "base_url"

      http_method = :post
      status = 202
      default = true
      delay = 2
      content_type = "text/xml"

      templates.default_config do |defaults|
        defaults.http_method = http_method
        defaults.status = status
        defaults.default = default
        defaults.delay = delay
        defaults.content_type = content_type
      end

      template = templates.put('greeting', 'hello')

      template.http_method.should == http_method
      template.status.should == status
      template.default.should == default
      template.delay.should == delay
      template.content_type.should == content_type
    end
  end

  describe 'putting templates' do


    endpoint = "greeting"
    value = "hello"



    context 'template as parameter' do
      before :each do
        @base_url = "base_url"
        @templates = Templates.new(@base_url)
      end

      it 'should take a preconfigured template as a parameter' do

        template = Template.new 'endpoint', 'value'
        template.should_receive(:create)
        @templates.put template
        template.endpoint.should == "#{@base_url}/templates/endpoint"
      end

      it 'should accept a block to allow the template to be customised' do
        block_called = false
        template = Template.new 'endpoint', 'value'
        template.should_receive(:create)
        @templates.put(template) do |the_same_template|
          block_called = true
          the_same_template.should == template
        end
        block_called.should == true
      end
    end

    context 'endpoint and value as parameters' do
      before :each do
        @base_url = "base_url"
        @templates = Templates.new(@base_url)

        @template_mock = mock('template')
        Template.should_receive(:new).with("#{@base_url}/templates/#{endpoint}", value, @templates.default_config).and_return(@template_mock)
        @template_mock.should_receive(:create)
      end

      it 'should create a template' do
        @templates.put(endpoint, value)
      end

      it 'should accept a block to allow the template to be customised' do
        block_called = false
        @templates.put(endpoint, value) do |template|
          block_called = true
          template.should == @template_mock
        end
        block_called.should == true
      end
    end
  end
end