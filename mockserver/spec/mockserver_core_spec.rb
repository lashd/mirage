require 'rspec'
require 'spec_helper'



describe 'mockserver' do
  include Web

  before do
    get('/mockserver/clear')
  end

  it 'should let you peek a default response' do
    response_id = get("/mockserver/set/greeting", :response=>"hello").body
    puts "response id is: #{response_id}"
    get("/mockserver/peek/#{response_id}").body.should == 'hello'
  end

  it 'should let you peek a patterned response' do
    expected_response = 'patterned_response'
    response_id = get("/mockserver/set/greeting", :response=>expected_response, :pattern=>'pattern').body
    get("/mockserver/peek/#{response_id}").body.should == expected_response
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
