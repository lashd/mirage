Before do
  get('/mockserver/clear')
  @response_ids = {}
end

Given /^the response for '(.*?)' is:$/ do |endpoint, text|
  @response_ids[endpoint]||=[]
  response_id = get("/mockserver/set/#{endpoint}", :response => text).body
  @response_ids[endpoint]<< response_id
end

When /^getting '(.*?)'$/ do |endpoint|
  @response = get("/mockserver/get/#{endpoint}")
end

When /^a response for '(.*?)' with pattern '(.*?)'$/ do |endpoint, pattern, text|
  get("/mockserver/set/#{endpoint}", :response => text, :pattern=> pattern)
end

When /^getting '(.*?)' with request body:$/ do |endpoint, request_body|
  @response = get("/mockserver/get/#{endpoint}", :body => request_body)
end

Then /^'(.*?)' should be returned$/ do |expected_response|
  @response.body.should == expected_response
end

When /^getting '(.*?)' with request parameters:$/ do |endpoint, table|
  parameters = {}
  table.hashes.each do |hash|
    parameters[hash['parameter'].to_sym] = hash['value']
  end
  @response = get("/mockserver/get/#{endpoint}", parameters)
end

Then /^a (404|500) should be returned$/ do |error_code|
  @response.code.should == error_code.to_i
end

When /^I clear '(.*?)' (responses|requests) from the MockServer$/ do |endpoint, thing|
  endpoint.downcase == 'all' ? get("/mockserver/clear/#{thing}/").code.should == 200 : get("/mockserver/clear/#{thing}/#{endpoint}").code.should == 200
end

Then /^'(.*?)' should have been tracked for '(.*?)'$/ do |text, endpoint|
  get("/mockserver/check/#{response_id(endpoint)}").body.should == text
end


When /^peeking at the response for '(.*?)'$/ do |endpoint|
  get("/mockserver/peek/#{response_id(endpoint)}")
end

Then /^the response ids for '(.*?)' should be the same$/ do |endpoint|
  response_ids = @response_ids[endpoint]
  response_ids.each{|response_id| response_id.should == response_ids.first}
end

Given /^an attempt is made to set '(.*?)' without a response$/ do |endpoint|
  @response = get("/mockserver/set/#{endpoint}")
end

Then /^tracking the last request for '(.*?)' should return a 404$/ do |endpoint|
  get("/mockserver/check/#{response_id(endpoint)}").code.should == 404
end


def response_id(endpoint)
  @response_ids[endpoint].first
end
