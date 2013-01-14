require 'spec_helper'
require 'binary_data_checker'

include Mirage
describe BinaryDataChecker do
  include_context :resources
  it 'should find binary data' do
    BinaryDataChecker.contains_binary_data?(File.read("#{resources_dir}/binary.file")).should == true
  end

  it 'should not find binary data' do
    BinaryDataChecker.contains_binary_data?("string").should == false
  end

  it 'should clean up the temporary file created when checking string content' do
    tmpfile = Tempfile.new("file")
    Tempfile.should_receive(:new).and_return tmpfile
    FileUtils.should_receive(:rm).with(tmpfile.path)
    BinaryDataChecker.contains_binary_data?("string")
  end
end