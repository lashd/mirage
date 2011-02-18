Before do
  get('/mockserver/clear')
end

Given /^the response for '(.*?)'$/ do |endpoint, text|
  get("/mockserver/set/#{endpoint}", :response => text)
end

When /^get '(.*?)'$/ do |endpoint|
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
When /^getting '(.*?)' with query string:$/ do |endpoint, table|
  parameters = {}
  table.hashes.each do |hash|
    parameters[hash['parameter'].to_sym] = hash['value']
  end
  @response = get("/mockserver/get/#{endpoint}", parameters)
end

Then /^a 404 should be returned$/ do
  @response.code.should == 404
end

When /^I clear '(.*?)' responses from the MockServer$/ do |endpoint|
  endpoint.downcase == 'all' ? get("/mockserver/clear/responses/").code.should == 200 : get("/mockserver/clear/responses/#{endpoint}").code.should == 200
end