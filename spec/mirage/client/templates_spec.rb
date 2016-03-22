require 'spec_helper'
require 'mirage/client'

describe 'templates' do


  describe 'deleting' do
    it 'should delete all templates and associated request data' do
      base_url = "base_url"
      requests = double('requests')
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

      templates.default_config do
        http_method http_method
        status status
        default default
        delay delay
        content_type content_type
      end

      template = templates.put('greeting', 'hello')

      template.http_method.should == http_method
      template.status.should == status
      template.default.should == default
      template.delay.should == delay
      template.content_type.should == content_type
    end

    it 'should fall over to methods on the caller if the method does not exist on the configuration object' do
      templates_wrapper = Class.new do
        def initialize
          @templates = Templates.new "base_url"
          @outer_method_called = false
        end

        def outer_method_call
          @outer_method_called = true
        end


        def outer_method_called?
          @outer_method_called
        end

        def test
          @templates.default_config do
            outer_method_call
          end
        end
      end


      wrapper = templates_wrapper.new

      wrapper.test
      wrapper.outer_method_called?.should == true

    end
  end

  describe 'putting templates' do


    endpoint = "greeting"
    value = "hello"
    let(:base_url) { "base_url" }
    let!(:templates) { Templates.new(base_url) }
    let!(:model_class) do
      Class.new do
        extend Template::Model
        endpoint endpoint

        def create
          self
        end
      end
    end


    context 'model as parameter' do
      let!(:endpoint) { 'endpoint' }

      before :each do
        @base_url = "base_url"
        @templates = Templates.new(@base_url)
      end
      it 'should take a model as a parameter' do
        template = model_class.new
        template = @templates.put template
        template.endpoint.should == "#{@base_url}/templates/#{endpoint}"
      end

      it 'should prepend base url to the endpoint unless it is set already' do
        original_template = model_class.new
        stored_template = @templates.put original_template
        stored_template.endpoint.should == "#{@base_url}/templates/#{endpoint}"
        stored_template = @templates.put original_template
        stored_template.endpoint.should == "#{@base_url}/templates/#{endpoint}"
      end

      it 'should fall over to methods on the caller if the method does not exist on the template object' do
        template_wrapper = Class.new do
          def initialize
            @templates = Templates.new "base_url"
            @outer_method_called = false
          end

          def outer_method_call
            @outer_method_called = true
          end

          def outer_method_called?
            @outer_method_called
          end

          def test
            template = Template.new 'endpoint'
            Template.should_receive(:new).and_return template
            template.stub(:create).and_return(template)
            @templates.put('endpoint', 'value') do |response|
              outer_method_call
            end
          end
        end

        wrapper = template_wrapper.new

        template = wrapper.test
        wrapper.outer_method_called?.should == true
        template.caller_binding.should == nil

      end


    end

    context 'endpoint and value as parameters' do
      before :each do
        @base_url = "base_url"
        @templates = Templates.new(@base_url)

        @template_mock = double('template')
        Template.should_receive(:new).with("#{@base_url}/templates/#{endpoint}", value, @templates.default_config).and_return(@template_mock)
        @template_mock.should_receive(:create)
      end

      it 'should create a template' do
        @templates.put(endpoint, value)
      end
    end

    context 'endpoint and model as parameters' do
      it 'should put the given template on the given endpoint' do
        @base_url = "base_url"
        @templates = Templates.new(@base_url)

        template = model_class.new
        template  = @templates.put 'greeting', template
        template.endpoint.should == "#{@base_url}/templates/greeting"
      end
    end

    describe 'block parameter that can be used for template customisation' do
      it 'it is called in the context of the template' do
        template = Template.new('', '')
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