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
    let(:base_url){ "base_url"}
    let!(:templates){Templates.new(base_url)}




    context 'model as parameter' do
      let!(:endpoint){'endpoint'}
      let!(:model_class) do
        Class.new do
          extend Template::Model
          endpoint endpoint
        end
      end
      before :each do
        @base_url = "base_url"
        @templates = Templates.new(@base_url)
      end
      it 'should take a model as a parameter' do
        template = model_class.new
        template.should_receive(:create)
        @templates.put template
        template.endpoint.should == "#{@base_url}/templates/#{endpoint}"
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


    end

    describe 'block parameter that can be used for template customisation' do
      it 'it is called in the context of the template' do
        template = Template.new('','')
        template.stub(:create)
        Template.should_receive(:new).and_return(template)
        templates.put(endpoint, value) do
          status 404
        end
        template.status.should == 404
      end

    end

  end
end