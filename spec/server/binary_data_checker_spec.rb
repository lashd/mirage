require 'spec_helper'
require 'binary_data_checker'


describe Mirage::BinaryDataChecker do
  include_context :resources
  it 'should find binary data' do
    expect(BinaryDataChecker.contains_binary_data?(File.read("#{resources_dir}/binary.file"))).to eq(true)
  end

  it 'should not find binary data' do
    expect(BinaryDataChecker.contains_binary_data?("string")).to eq(false)
  end

  it 'should clean up the temporary file created when checking string content' do
    tmpfile = Tempfile.new("file")
    expect(Tempfile).to receive(:new).and_return tmpfile
    expect(FileUtils).to receive(:rm).with(tmpfile.path)
    BinaryDataChecker.contains_binary_data?("string")
  end
end