require 'rspec'
require 'spec_helper'
require 'mechanize'
require 'fileutils'

describe 'hosting files on the mockserver' do

  before do
    @spec_dir = File.dirname(__FILE__)
    @download_path = "#{@spec_dir}/download.zip"
    FileUtils.rm_f(@download_path)

    @browser = Mechanize.new
    @browser.get("#{MOCKSERVER_URL}/clear")
  end

  it 'should host a file' do
    file = File.new("#{@spec_dir}/test.zip")

    @browser.post("#{MOCKSERVER_URL}/set/file_response", :file=>file)

    download = @browser.get("#{MOCKSERVER_URL}/get/file_response")
    download.filename.should == File.basename(file.path)
    download.save_as(@download_path)

    FileUtils.cmp(file, File.new(@download_path)).should == true
  end
end