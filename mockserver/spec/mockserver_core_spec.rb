require 'rspec'
require 'spec_helper'



describe 'mockserver' do
  include Web

  before do
    get('/mockserver/clear')
  end

  it 'should return a 404 when response not found' do
    response = get('/mockserver/get/something')
    response.code.should == 404
  end

  it 'should look in the url for the pattern' do
    get('/mockserver/set/logs', :response=>'logs')
    get('/mockserver/set/logs/choicpaapp71.bskyb.com', :response=>'node')
    get('/mockserver/set/logs/chiocpaapp71.bskyb.com/sstp_tomcat-eservice', :response=>'tomcat_logs')


    get('/mockserver/get/logs').body.should == 'logs'
    get('/mockserver/get/logs/choicpaapp71.bskyb.com').body.should == 'node'
    get('/mockserver/get/logs/chiocpaapp71.bskyb.com/sstp_tomcat-eservice').body.should == 'tomcat_logs'

  end

  it 'should clear all responses' do
    get('/mockserver/set/greeting/default', :response=>'hello')
    get('/mockserver/set/greeting', :response =>'hello')
    get('/mockserver/set/message/default', :response=> 'world')
    get('/mockserver/set/message/world')

    get('/mockserver/clear')
    get('/mockserver/get/greeting').code.should == 404
    get('/mockserver/get/message').code.should == 404
  end

  it 'should clear responses for key' do
    get('/mockserver/set/message', :response=> 'hello')
    get('/mockserver/clear/message')
    get('/mockserver/get/message').code.should == 404

    get('/mockserver/set/message/world')
    get('/mockserver/clear/message')
    get('/mockserver/get/message').code.should == 404

    get('/mockserver/set/message/', :response=>'hello')
    get('/mockserver/clear/message')
    get('/mockserver/get/message').code.should == 404
  end

  it 'should return a 500 if a response is not supplied' do
    get("/mockserver/set/greeting").code.should == 500
  end


  it 'should return request params sent in url' do
    response_id = get('/mockserver/set/hitbox', :response=>'hitbox').body
    get('/mockserver/get/hitbox', :hitbox_id=>'link1').body
    get("/mockserver/check/#{response_id}/query").body.should == "hitbox_id=link1"
  end

  it 'should keep the same response id for a response that is set more than once' do
    first_id = get('/mockserver/set/hitbox', :response=>'default').body
    second_id = get('/mockserver/set/hitbox', :response=>'default').body

    first_id.should == second_id

    third_id = get('/mockserver/set/hitbox', :response=>'pattern', :pattern=>'pattern').body
    third_id.should_not == first_id

    fourth_id = get('/mockserver/set/hitbox', :response=>'pattern', :pattern=>'pattern').body
    third_id.should == fourth_id
  end


  it 'should return request when sent in body' do
    response_id = get('/mockserver/set/hitbox', :response=>'hitbox').body
    get('/mockserver/get/hitbox', :body => 'whatever')
    get("/mockserver/check/#{response_id}/body").body.should == 'whatever'
  end


  it 'should return a 404 if when check for something that is not being tracked' do
    get('/mockserver/check/something/query').code.should == 404
  end

  it 'should pattern match url to access responses' do

    get('/mockserver/set/greeting', :response=>'hello')
    get('/mockserver/get/greeting/with/more/stuff/in/url').body.should == 'hello'

  end

  it 'should clear tracked responses' do
    get('/mockserver/set/hitbox', :response=>'hitbox')
    get('/mockserver/set/greeting', :response=>'hitbox')
    get('/mockserver/clear/responses')
    get("/mockserver/get/hitbox").code.should==404
    get("/mockserver/get/greeting").code.should==404
  end

  it 'should clear tracked requests' do
    hitbox_response_id = get('/mockserver/set/hitbox', :response=>'hitbox').body
    greeting_response_id = get('/mockserver/set/greeting', :response=>'hitbox').body

    get('/mockserver/get/hitbox', :request=>'blah')
    get('/mockserver/get/greeting', :request=>'blah')
    get('/mockserver/clear/requests')

    get("/mockserver/check/#{hitbox_response_id}/query").code.should == 404
    get("/mockserver/check/#{greeting_response_id}/query").code.should == 404
  end


  it 'should clear requests for a stack' do
    get('/mockserver/set/greeting', :response=>'hallo')
    get('/mockserver/get/greeting', :query=>'value')

    get('/mockserver/clear/requests/greeting')

    get('/mockserver/check/greeting/query').code.should == 404
    get('/mockserver/get/greeting').code.should == 200
  end

  it 'should clear responses for a stack' do
    get('/mockserver/set/greeting', :response=>'hallo').body
    get('/mockserver/set/hitbox', :response=>'sitecat').body


    get('/mockserver/clear/responses/greeting')

    get('/mockserver/get/greeting').code.should == 404
    get('/mockserver/get/hitbox').code.should == 200
  end


  it 'should clear everything' do
    hitbox_response_id = get('/mockserver/set/hitbox', :response=>'hitbox').body
    get('/mockserver/get/hitbox', :request=>'blah').body

    get('/mockserver/clear')

    get("/mockserver/check/#{hitbox_response_id}/query").code.should == 404
    get('/mockserver/get/hitbox').code.should == 404
  end

  it 'should allow a delay to be set before a response is returned' do
    delay = 1
    get("/mockserver/set/greeting", :response=>'hello', :delay=>delay)
    test_start_time = Time.now
    get('/mockserver/get/greeting')
    test_finish_time = Time.now
    (test_finish_time - test_start_time).should >= delay
  end

  it 'should let you peek a default response' do
    response_id = get("/mockserver/set/greeting", :response=>"hello").body
    get("/mockserver/peek/#{response_id}").body.should == 'hello'
  end

  it 'should let you peek a patterned response' do
    expected_response = 'patterned_response'
    response_id = get("/mockserver/set/greeting", :response=>expected_response, :pattern=>'pattern').body
    get("/mockserver/peek/#{response_id}").body.should == expected_response
  end

  it 'should not remove stored request on peek' do
    response_id = get('/mockserver/set/hitbox', :response=>'hitbox').body
    get('/mockserver/get/hitbox', :hitbox_id=>'link1')
    get("/mockserver/peek/#{response_id}")
    get("/mockserver/check/#{response_id}/query").body.should == "hitbox_id=link1"
  end

  it 'should return a 404 when trying to peek for a request that does not exist' do
    get("/mockserver/peek/100").code.should == 404
  end


  it 'should replace pattern with value found in request body when pattern is matched' do

    body =<<BODY
<greeting>
  <id>body_value</id>
</greeting>
BODY

    response = "<message>$id>(.*)?<$</message>"
    get("/mockserver/set/greeting", :response=>response)
    get('/mockserver/get/greeting', :body => body).body.should == "<message>body_value</message>"
  end

  it 'should leave pattern alone when there is neither a default replacement or a match in the query string' do
    response = "<message>$id>(.*)?<$</message>"
    get("/mockserver/set/greeting", :response=>response)
    get('/mockserver/get/greeting', :body => '<message>hello</message>').body.should == response
  end

  it 'should reset mocks back to snapshot' do
    get("/mockserver/set/greeting", :response=>"hello")
    get("/mockserver/snapshot")
    get("/mockserver/set/greeting", :response=>"yo")
    get("/mockserver/get/greeting").body.should == 'yo'
    get("/mockserver/rollback")
    get("/mockserver/get/greeting").body.should == 'hello'
  end


  it 'should replace pattern from response with value in the query string' do
    response = "<message>$value=_(.*?)_$</message>"
    get("/mockserver/set/greeting", :response=>response)
    get('/mockserver/get/greeting?value=_replaced_').body.should == "<message>replaced</message>"
  end

  it 'should leave pattern alone when there in not a match in the query string' do
    response = "<message>$value$</message>"
    get("/mockserver/set/greeting", :response=>response)
    get('/mockserver/get/greeting').body.should == "<message>$value$</message>"
  end

end
