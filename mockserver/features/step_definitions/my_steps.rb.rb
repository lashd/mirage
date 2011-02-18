Given /^the response for '(.*?)'$/ do |endpoint,text|
  @expected_response = text
  get("/mockserver/set/#{endpoint}", :response => @expected_response)
end
When /^getting '(.*?)'$/ do |endpoint|
  @response = get("/mockserver/get/#{endpoint}").body
end
Then /^the response should be returned$/ do
  @expected_response.should == @response
end