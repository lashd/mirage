require 'spec_helper'
require 'mirage/client'



describe Mirage::Response do
  include Mirage

  describe 'body requirements' do
    it 'should set up plain text matches' do
      response = Response.new "hello"
      response.add_body_content_requirement "leon"
      response.headers.select{|key,value| key.start_with?('x-mirage-required_body_content')}.values.should == %w(leon)
    end

    it 'should set up regexp matches' do
      response = Response.new "hello"
      response.add_body_content_requirement /leon/
      response.headers.select{|key,value| key.start_with?('x-mirage-required_body_content')}.values.should == %w(%r{leon})
    end
  end

  describe "request parameter requirements" do
    it 'should set up plain text matches' do
      response = Response.new "hello"
      response.add_request_parameter_requirement :name, "leon"
      response.headers.select{|key,value| key.start_with?('x-mirage-required_parameter')}.values.should == %w(name:leon)
    end

    it 'should set up regexp matches' do
      response = Response.new "hello"
      response.add_request_parameter_requirement :name, /leon/
      response.headers.select{|key,value| key.start_with?('x-mirage-required_parameter')}.values.should == %w(name:%r{leon})
    end
  end
end
