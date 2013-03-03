require 'spec_helper'
require 'mirage/client'

describe Mirage::Client do
  include Mirage

  before :each do
    @response = mock('response').as_null_object
  end

  describe 'configuration' do
    it 'is configured to connect to local host port 7001 by default' do
      Client.new.url.should == "http://localhost:7001/mirage"
    end

    it 'can be configured with a url pointing to Mirage' do
      mirage_url = "http://url.for.mirage"
      Client.new(mirage_url).url.should == mirage_url

      Client.new(:url => mirage_url).url.should == mirage_url
    end

    it 'can be configured with a port refering to which port Mirage is running on on localhost' do
      port = 9001
      Client.new(:port => port).url.should == "http://localhost:#{port}/mirage"
    end

    it 'raises an error if neither a port or url specified in the argument' do
      expect { Client.new({}) }.to raise_error()
      expect { Client.new("rubbish") }.to raise_error()
    end

    describe 'setting template defaults' do

    end
  end


  it 'should prime mirage' do
    Client.should_receive(:put) do |url|
      url.should == "http://localhost:7001/mirage/defaults"
    end
    Client.new.prime
  end

  describe 'templates' do
    it 'should give access to templates' do
      mirage = Client.new
      mirage.templates.instance_of?(Templates).should == true
    end

    it 'should find a template' do
      id = 1
      mirage = Client.new
      Template.should_receive(:get).with("#{mirage.url}/#{id}")
      mirage.templates(1)
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
      Request.should_receive(:get).with("#{mirage.url}/#{id}")
      mirage.requests(id)
    end
  end






  describe 'reset' do
    #Client.should_receive(:put) do |url|
    #  url.should == "http://localhost:7001/mirage/defaults"
    #end
    #Client.new.prime
  end

  describe 'stop' do

  end


  describe 'save' do

  end

  describe 'revert' do

  end

  describe 'running?' do

  end


  #describe 'interface to mirage' do
  #  before :each do
  #    Mirage.start
  #  end
  #
  #  after do
  #    Mirage.stop
  #  end
  #
  #  it 'should set a response' do
  #    client = Client.new
  #    response_id = client.put "greeting", "hello"
  #    response_id.should == 1
  #  end
  #end
end
