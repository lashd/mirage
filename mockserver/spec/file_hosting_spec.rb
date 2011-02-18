require 'rspec'
require 'net/http'
require 'mechanize'
require 'fileutils'


module Web
  def get url, body = nil
    response = Net::HTTP.start("localhost", 7000) do |http|
      request = Net::HTTP::Get.new(url)
      request.body=body if body
      http.request(request)
    end

    def response.code
      @code.to_i
    end

    response
  end
end

describe 'hosting files on the mockserver' do
  include Web

  before do
    get('/mockserver/clear')
    FileUtils.rm_f("#{File.dirname(__FILE__)}/download.zip")
  end

  it 'should host a file' do
    browser = Mechanize.new
    spec_dir = File.dirname(__FILE__)
    file = File.new("#{spec_dir}/test.zip")
    browser.post("http://localhost:7000/mockserver/set/file_response", :file=>file)

    download = browser.get("http://localhost:7000/mockserver/get/file_response")
    download.save_as("#{spec_dir}/download.zip")

    FileUtils.cmp(file, File.new("#{spec_dir}/download.zip")).should == true

#    file.should == File.new("#{spec_dir}/download.zip")
  end
end