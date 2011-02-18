require 'rspec'
require 'spec_helper'
require 'mechanize'
require 'fileutils'

describe 'hosting files on the mockserver' do
  include Web

  before do
    @spec_dir = File.dirname(__FILE__)
    @download_path = "#{@spec_dir}/download.zip"
    FileUtils.rm_f(@download_path)

    @browser = Mechanize.new
    get("/mockserver/clear")
  end

  it 'should host a file' do
    test_file_path = "#{@spec_dir}/test.zip"
    test_file = File.new(test_file_path)

    post("/mockserver/set/file_response", :file=>test_file)

    download = get("/mockserver/get/file_response")
    download.filename.should == File.basename(test_file.path)
    download.save_as(@download_path)

    FileUtils.cmp(test_file_path, @download_path).should == true
  end
end