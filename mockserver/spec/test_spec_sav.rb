require 'rubygems'
require 'rspec'
require 'rack/test'
require 'ramaze'
require 'test'

describe 'something' do

  include Rack::Test::Methods

  def app
    Ramaze.middleware

  end


 it 'should return file' do
    response = post("/", :file => Rack::Test::UploadedFile.new('/home/user/dev/eservice/mock-server/test.zip') )
    response.body

    1.should == 1

  end
end