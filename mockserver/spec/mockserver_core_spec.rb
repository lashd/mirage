require 'rspec'
require 'spec_helper'



describe 'mockserver' do
  include Web

  before do
    get('/mockserver/clear')
  end


  it 'should return a 404 when trying to peek for a request that does not exist' do
    get("/mockserver/peek/100").code.should == 404
  end


  it 'should reset mocks back to snapshot' do
    get("/mockserver/set/greeting", :response=>"hello")
    get("/mockserver/snapshot")
    get("/mockserver/set/greeting", :response=>"yo")
    get("/mockserver/get/greeting").body.should == 'yo'
    get("/mockserver/rollback")
    get("/mockserver/get/greeting").body.should == 'hello'
  end

end
