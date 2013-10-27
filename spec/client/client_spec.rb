require 'spec_helper'
require 'mirage/client'

describe Mirage::Client do


  before :each do
    @response = double('response').as_null_object
  end

  describe 'configuration' do
    it 'is configured to connect to local host port 7001 by default' do
      Client.new.url.should == "http://localhost:7001"
    end

    it 'can be configured with a url pointing to Mirage' do
      mirage_url = "http://url.for.mirage"
      Client.new(mirage_url).url.should == mirage_url

      Client.new(:url => mirage_url).url.should == mirage_url
    end

    it 'can be configured with a port refering to which port Mirage is running on on localhost' do
      port = 9001
      Client.new(:port => port).url.should == "http://localhost:#{port}"
    end

    it 'raises an error if neither a port or url specified in the argument' do
      expect { Client.new({}) }.to raise_error()
      expect { Client.new("rubbish") }.to raise_error()
    end


    describe 'defaults' do
      it 'can be configured with template defaults on initialize' do
        templates, config = Templates.new("url"), proc {}
        Templates.should_receive(:new).and_return(templates)
        templates.should_receive(:default_config) do |&block|
          block.should == config
        end
        Client.new &config
      end

      it 'can be configured with template defaults on after initalize' do
        templates, config = Templates.new("url"), proc {}
        Templates.should_receive(:new).and_return(templates)
        templates.should_receive(:default_config) do |&block|
          block.should == config
        end
        Client.new.configure &config
      end

      it 'can be reset' do
        client = Client.new do
          http_method :post
        end

        client.reset
        client.templates.default_config.should == Template::Configuration.new
      end

    end
  end

  it 'should clear mirage' do
    templates_mock = double('templates')
    Templates.should_receive(:new).and_return(templates_mock)
    templates_mock.should_receive(:delete_all)
    Client.new.clear
  end




  it 'should prime mirage' do
    Client.should_receive(:put) do |url|
      url.should == "http://localhost:7001/defaults"
    end
    Client.new.prime
  end

  describe 'templates' do
    it 'should give access to templates' do
      mirage = Client.new
      mirage.templates.instance_of?(Templates).should == true
    end

    it 'The templates instance should be the one created on construction otherwise the defaults passed in will get lost' do
      mirage = Client.new
      mirage.templates.should == mirage.templates
    end

    it 'should find a template' do
      id = 1
      mirage = Client.new
      mock_template = double('template')
      Template.should_receive(:get).with("#{mirage.url}/templates/#{id}").and_return(mock_template)
      mirage.templates(1).should == mock_template
    end


    describe 'put' do
      it "should put a response on mirage by passing args on to template's put method "  do
        endpoint, value, block = 'greeting', 'hello', Proc.new{}

        templates_mock = double('templates')
        Templates.should_receive(:new).and_return(templates_mock)

      templates_mock.should_receive(:put).with(endpoint, value, &block)

        mirage = Client.new
        mirage.put endpoint, value, &block
      end
    end
  end

  describe 'requests' do
    it 'should give access to requests' do
      mirage = Client.new
      mirage.requests.instance_of?(Requests).should == true
    end

    it 'should find a request' do
      id = 1
      mirage = Client.new
      Request.should_receive(:get).with("#{mirage.url}/requests/#{id}")
      mirage.requests(id)
    end
  end

  describe 'save' do
    it 'should save the current template setup of mirage' do
      mirage = Client.new
      Client.should_receive(:put).with("#{mirage.url}/backup", :body => "")
      mirage.save
    end
  end

  describe 'revert' do
    it 'should revert the current template set' do
      mirage = Client.new
      Client.should_receive(:put).with(mirage.url, :body => "")
      mirage.revert
    end
  end

  describe 'running?' do
    it 'should check if mirage is runing' do
      url = 'http://some_url'

      Mirage.should_receive(:running?).with url
      Client.new(url).running?
    end
  end


  describe 'interface to mirage' do

    after :each do
      Mirage.stop
    end

    it 'should set a response' do
      client = Mirage.start
      response = client.templates.put("greeting", "hello")
      response.id.should == 1
    end

    it 'should find mirage running' do
      Mirage.start
      Mirage.running?.should == true
    end

    it 'should not find mirage running' do
      Mirage.running?.should == false
    end

  end
end
