Before do
  get('/mockserver/clear')
end

Given /^the response for '(.*?)'$/ do |endpoint, text|
  @expected_response = text
  get("/mockserver/set/#{endpoint}", :response => @expected_response)
end

When /^getting '(.*?)'$/ do |endpoint|
  @response = get("/mockserver/get/#{endpoint}").body
end

When /^a response for '(.*?)' with pattern '(.*?)'$/ do |endpoint, pattern, text|
  @expected_response = text
  get("/mockserver/set/#{endpoint}", :response => @expected_response, :pattern=> pattern)
end

When /^getting '(.*?)' with request body:$/ do |endpoint, request_body|
  @response = get("/mockserver/get/#{endpoint}", :body => request_body).body
end
Then /^the response should be '(.*?)'$/ do |expected_response|
   @response.should == expected_response
end
When /^getting '(.*?)' with query string:$/ do |endpoint, table|
  parameters = {}
  table.hashes.each do |hash|
    parameters[hash['parameter'].to_sym] = hash['value']
  end
  @response = get("/mockserver/get/#{endpoint}", parameters).body
end