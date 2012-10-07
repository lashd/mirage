require 'spec_helper'
require 'mock_response'
require 'server'
require 'helpers'

describe "helpers" do
  include_context :resources

  before :each do
    @helper = Object.new
    @helper.extend(Mirage::Server::Helpers)
  end

  describe 'converting raw parameter requirements' do
    it 'should split on split on the (:) to derive the required parameter and value' do
      @helper.convert_raw_required_params(%w(name:leon)).should == {'name' => 'leon'}
    end

    it 'should store regular expression matcher' do
      @helper.convert_raw_required_params(%w(name:%r{.*eon})).should == {'name' => /.*eon/}
    end
  end

  describe 'converting raw body content requirements' do
    it 'should extract plan text requirements' do
      @helper.convert_raw_required_body_content_requirements(%w(leon)).should == %w(leon)
    end

    it 'should extract plan requirements in the form of a regexp' do
      @helper.convert_raw_required_body_content_requirements(%w(%r{.*eon})).should == [/.*eon/]
    end
  end

  describe 'checking for binary data in strings' do
    it 'should find binary data' do
      @helper.contains_binary_data?(File.read("#{resources_dir}/binary.file")).should == true
    end

    it 'should not find binary data' do
      @helper.contains_binary_data?("string").should == false
    end

    it 'should clean up the temporary file created when checking string content' do
      tmpfile = Tempfile.new("file")
      Tempfile.should_receive(:new).and_return tmpfile
      FileUtils.should_receive(:rm).with(tmpfile.path)

      @helper.contains_binary_data?("string")
    end
  end
end