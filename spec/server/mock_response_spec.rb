require 'spec_helper'
require 'extensions/object'
require 'mock_response'

describe Mirage::MockResponse do
  include Mirage
  before :each do
    MockResponse.delete_all
  end

  describe 'saving state' do
    it 'should store the current set of responses' do
      greeting = MockResponse.new("greeting", "hello")
      farewell = MockResponse.new("farewell", "goodbye")

      MockResponse.backup
      MockResponse.new("farewell", "cheerio")
      MockResponse.revert

      MockResponse.all.should == [greeting, farewell]
    end
  end

  describe "response values" do
    it 'should return the response value' do
      MockResponse.new("greeting", "hello").value.should == "hello"
    end

    #TODO - file is a bit misguided it is the content type that decides what dialogue the browser offers you
    it 'should just return the value if it is a file' do
      MockResponse.new("greeting", "hello ${name}", :binary => true).value("", {"name" => "leon"}).should == "hello ${name}"
    end

    it 'should replace patterns with values found in request parameters' do
      MockResponse.new("greeting", "hello ${name}").value("", {"name" => "leon"}).should == "hello leon"
    end
    it 'should replace patterns with values found in the body' do
      MockResponse.new("greeting", "hello ${name>(.*?)<}").value("<name>leon</name>").should == "hello leon"
    end

    it 'should search for patterns in the querystring' do
      MockResponse.new("greeting", "hello ${name=(.*)}").value("", {}, "name=leon").should == "hello leon"
    end
  end

  describe "Matching http method" do
    it 'should find the response with the correct http method' do
      response = MockResponse.new("greeting", "hello",
                                  :http_method => "post")

      MockResponse.find("", {}, "greeting", "post").should == response
      expect { MockResponse.find("", {}, "greeting", "get") }.to raise_error(ServerResponseNotFound)
    end
  end

  describe 'Finding by id' do
    it 'should find a response given its id' do
      response1 = MockResponse.new("greeting", "hello")
      MockResponse.new("farewell", "goodbye")
      MockResponse.find_by_id(response1.response_id).should == response1
    end
  end

  describe 'deleting' do

    it 'should delete a response given its id' do
      response1 = MockResponse.new("greeting", "hello")
      MockResponse.delete(response1.id)
      expect { MockResponse.find_by_id(response1.id) }.to raise_error(ServerResponseNotFound)
    end

    it 'should delete all responses' do
      MockResponse.new("greeting", "hello")
      MockResponse.new("farewell", "goodbye")
      MockResponse.delete_all
      MockResponse.all.size.should == 0
    end

  end

  describe "matching on request parameters" do
    it 'should find the response if all required parameters are present' do
      get_response = MockResponse.new("greeting", "get response", :http_method => "get", :required_parameters => {:firstname => "leon"})
      post_response = MockResponse.new("greeting", "post response", :http_method => "post", :required_parameters => {:firstname => "leon"})

      MockResponse.find("", {:firstname => "leon"}, "greeting", "post").should == post_response
      MockResponse.find("", {:firstname => "leon"}, "greeting", "get").should == get_response
    end

    it 'should match request parameter values using regexps' do
      response = MockResponse.new("greeting", "response", :required_parameters => {:firstname => /leon.*/})

      MockResponse.find("", {:firstname => "leon"}, "greeting", "get").should == response
      MockResponse.find("", {:firstname => "leonard"}, "greeting", "get").should == response
      expect { MockResponse.find("", {:firstname => "leo"}, "greeting", "get") }.to raise_error(ServerResponseNotFound)
    end
  end

  describe 'matching against the request body' do
    it 'should match required fragments in the request body' do
      response = MockResponse.new("greeting", "response", :required_body_content => %w(leon))
      MockResponse.find("<name>leon</name>", {}, "greeting", "get").should == response
      expect { MockResponse.find("<name>jeff</name>", {}, "greeting", "get") }.to raise_error(ServerResponseNotFound)
    end

    it 'should use regexs to match required fragements in the request body' do
      response = MockResponse.new("greeting", "response", :required_body_content => [/leon.*/])
      MockResponse.find("<name>leon</name>", {}, "greeting", "get").should == response
      MockResponse.find("<name>leonard</name>", {}, "greeting", "get").should == response
      expect { MockResponse.find("<name>jef</name>", {}, "greeting", "get") }.to raise_error(ServerResponseNotFound)
    end
  end

  it 'should be equal to another response that is the same not including the response value' do
    response = MockResponse.new("greeting", "hello1", :content_type => "text/xml",
                                :http_method => "post",
                                :status => 202,
                                :delay => 1.0,
                                :default => true,
                                :file => false)
    response.should_not == MockResponse.new("greeting", "hello", {})
    response.should == MockResponse.new("greeting", "hello2", :content_type => "text/xml",
                                        :http_method => "post",
                                        :status => 202,
                                        :delay => 1.0,
                                        :default => true,
                                        :file => false)
  end

  describe "scoring to represent the specificity of a response" do

    it 'should score an exact requirement match at 2' do
      MockResponse.new("greeting", "response", :required_parameters => {:firstname => "leon"}).score.should == 2
      MockResponse.new("greeting", "response", :required_body_content => %w(login)).score.should == 2
    end

    it 'should score a match found by regexp at 1' do
      MockResponse.new("greeting", "response", :required_parameters => {:firstname => /leon.*/}).score.should == 1
      MockResponse.new("greeting", "response", :required_body_content => [/input|output/]).score.should == 1
    end

    it 'should find the most specific response' do
      MockResponse.new("greeting", "default response", :required_body_content => %w(login))
      expected_response = MockResponse.new("greeting", "specific response", :required_body_content => %w(login), :required_parameters => {:name => "leon"})
      MockResponse.find("<action>login</action>", {:name => "leon"}, "greeting", "get").should == expected_response
    end
  end


  it 'should all matching to be based on body content, request parameters and http method' do
    response = MockResponse.new("greeting", "response", :required_body_content => %w(login), :required_parameters => {:name => "leon"}, :http_method => "post")
    MockResponse.find("<action>login</action>", {:name => "leon"}, "greeting", "post").should == response
    expect { MockResponse.find("<action>login</action>", {:name => "leon"}, "greeting", "get") }.to raise_error(ServerResponseNotFound)
  end

  it 'should recycle response ids' do
    response1 = MockResponse.new("greeting", "response1", :required_body_content => %w(login), :required_parameters => {:name => "leon"}, :http_method => "post")
    response2 = MockResponse.new("greeting", "response2", :required_body_content => %w(login), :required_parameters => {:name => "leon"}, :http_method => "post")

    response1.response_id.should_not == nil
    response1.response_id.should == response2.response_id
  end

  it 'should raise an exception when a response is not found' do
    expect { MockResponse.find("<action>login</action>", {:name => "leon"}, "greeting", "post") }.to raise_error(ServerResponseNotFound)
  end

  it 'should return all responses' do
    MockResponse.new("greeting", "hello")
    MockResponse.new("greeting", "hello leon", :required_body_content => %w(leon))
    MockResponse.new("greeting", "thank you", :required_body_content => %w(hello), :http_method => "post")
    MockResponse.new("deposit", "received", :required_body_content => %w(amount), :http_method => "post")
    MockResponse.all.size.should == 4
  end

  describe 'finding defaults' do
    it 'most appropriate response under parent resource and same http method' do
      level1_response = MockResponse.new("level1", "level1", :default => true)
      level2_response = MockResponse.new("level1/level2", "level2", :required_body_content => %w(body), :default => true)
      MockResponse.find_default("body", "get", "level1/level2/level3", {}).should == level2_response
      MockResponse.find_default("", "get", "level1/level2/level3", {}).should == level1_response
    end
  end

  it 'should generate subdomains' do
    MockResponse.subdomains("1/2/3").should == ["1/2/3", '1/2', '1']
  end

end