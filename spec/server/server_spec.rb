require 'spec_helper'

describe "Mirage Server" do
  include_context :rack_test, :disable_sinatra_error_handling => true

  describe "when adding responses" do
    it 'should parse required request parameters' do
      raw_required_parameter, converted_required_parameter = 'name:leon', {'name' => 'leon'}

      application_expectations do |app|
        app.should_receive(:convert_raw_required_params).with(%W(#{raw_required_parameter})).and_return(converted_required_parameter)
      end

      Mirage::MockResponse.should_receive(:new) do |name,response, details|
        details[:required_parameters].should == converted_required_parameter
        mock(:response_id => 1)
      end

      put('/mirage/templates/greeting',{}, "HTTP_X_MIRAGE_REQUIRED_PARAMETER1" => raw_required_parameter)
    end

    it 'should parse required body content' do
      raw_body_requirement, converted_body_requirement = 'leon', %w(leon)

      application_expectations do |app|
        app.should_receive(:convert_raw_required_body_content_requirements).with(%W(#{raw_body_requirement})).and_return(converted_body_requirement)
      end

      Mirage::MockResponse.should_receive(:new) do |name,response, details|
        details[:required_body_content].should == converted_body_requirement
        mock(:response_id => 1)
      end

      put('/mirage/templates/greeting',{}, "HTTP_X_MIRAGE_REQUIRED_BODY_CONTENT1" => raw_body_requirement)
    end

    it 'should mark binary content' do
      binary_body_content = "binary"
      application_expectations do |app|
        app.should_receive(:contains_binary_data?).with(binary_body_content).and_return(true)
      end

      Mirage::MockResponse.should_receive(:new) do |name,response, details|
        details[:binary].should == true
        mock(:response_id => 1)
      end

      put('/mirage/templates/greeting',binary_body_content)
    end
  end



  it 'should return the default response if a specific match is not found' do
    Mirage::MockResponse.should_receive(:find_default).with("","post", "greeting",{}).and_return(Mirage::MockResponse.new("greeting", "hello",{}))
    put('/mirage/templates/greeting',"hello leon", "HTTP_X_MIRAGE_REQUIRED_BODY_CONTENT1" => "leon", "Content-Type" => "POST")
    post('/mirage/responses/greeting')
  end



  describe "operations" do
    describe 'resolving responses' do
      it 'should return the default response' do
        put('/mirage/templates/level1',"level1")
        put('/mirage/templates/level1/level2',"level2", "HTTP_X_MIRAGE_DEFAULT" => "true")
        get('/mirage/responses/level1/level2/level3').body.should == "level2"
      end
    end

    it 'should let you check the content of a template' do
      response_id = put('/mirage/templates/greeting',"hello").body
      get("/mirage/templates/#{response_id}").body.should == "hello"
    end

    it 'should delete a template' do
      response_id = put('/mirage/templates/greeting',"hello").body
      delete("/mirage/templates/#{response_id}")
      expect{get("/mirage/templates/#{response_id}")}.to raise_error(Mirage::ServerResponseNotFound)
    end
  end
end
