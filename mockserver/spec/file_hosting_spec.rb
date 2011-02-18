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
    @test_file = File.new("#{@spec_dir}/test.zip")

    @browser = Mechanize.new
    get("/mockserver/clear")
  end

  it 'should host a file' do
    post("/mockserver/set/file_response", :file=>@test_file)

    download = get("/mockserver/get/file_response")
    download.save_as(@download_path)

    download.filename.should == File.basename(@test_file.path)
    FileUtils.cmp(@test_file.path, @download_path).should == true
  end
end