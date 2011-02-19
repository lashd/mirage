Before do
  get('/mockserver/clear')
end

Given /^the response for '([^']*)' is:$/ do |endpoint, text|
  @expected_text = text
  @endpoint = endpoint
  @response_id = get("/mockserver/set/#{endpoint}", :response => text).body
end

When /^the response for '([^']*)' with pattern '([^']*)' is:$/ do |endpoint, pattern, text|
  @response_id = get("/mockserver/set/#{endpoint}", :response => text, :pattern=> pattern).body
end

When /^getting '(.*?)'$/ do |endpoint|
  @response = get("/mockserver/get/#{endpoint}")
end

When /^getting '(.*?)' with request body:$/ do |endpoint, request_body|
  @response = get("/mockserver/get/#{endpoint}", :body => request_body)
end

When /^getting '(.*?)' with request parameters:$/ do |endpoint, table|
  parameters = {}
  table.hashes.each do |hash|
    parameters[hash['parameter'].to_sym] = hash['value']
  end
  @response = get("/mockserver/get/#{endpoint}", parameters)
end

Then /^'(.*?)' should be returned$/ do |expected_response|
  @response.body.should == expected_response
end

Then /^a (404|500) should be returned$/ do |error_code|
  @response.code.should == error_code.to_i
end

When /^I clear '(.*?)' (responses|requests) from the MockServer$/ do |endpoint, thing|
  endpoint.downcase == 'all' ? get("/mockserver/clear/#{thing}/").code.should == 200 : get("/mockserver/clear/#{thing}/#{endpoint}").code.should == 200
end

When /^peeking at the response for '(.*?)'$/ do |endpoint|
  get("/mockserver/peek/#{@response_id}")
end

Given /^an attempt is made to set '(.*?)' without a response$/ do |endpoint|
  @response = get("/mockserver/set/#{endpoint}")
end

Then /^tracking the request should return a 404$/ do
  get("/mockserver/check/#{@response_id}").code.should == 404
end

Then /^the response id should be '(\d+)'$/ do |response_id|
  @response_id.should == response_id
end
Then /^'(.*?)' should have been tracked$/ do |text|
  get("/mockserver/check/#{@response_id}").body.should == text
end
Then /^'(.*?)' should have been tracked for response id '(.*?)'$/ do |text, response_id|
   get("/mockserver/check/#{response_id}").body.should == text
end

Then /^tracking the request for response id '(.*?)' should return a 404$/ do |response_id|
  get("/mockserver/check/#{response_id}").code.should == 404
end
When /^a delay of '(.*)' seconds$/ do |delay|
  @start_time = Time.now
  @response_id = get("/mockserver/set/#{@endpoint}", :response => @expected_text, :delay => delay.to_f).body
end


Then /^it should take at least '(.*)' seconds$/ do |time|
 (Time.now - @start_time).should >= time.to_f
end