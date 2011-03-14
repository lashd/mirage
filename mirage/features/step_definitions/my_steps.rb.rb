require 'rake'
Before do
  ['custom_default_location', 'defaults'].each { |location| FileUtils.rm_rf(location) if ::File.exists?(location) }
  $mirage.clear
end

Before('@command_line') do
  stop_mirage
end

After('@command_line') do
  stop_mirage
  start_mirage
end


When /^the response for '([^']*)' (with pattern '([^']*)' )?(with a delay of '(\d+)' )?is:$/ do |endpoint, *args|

  options = {:response => args.delete_at(args.size()-1)}
  delay_regex = /with a delay of '(\d+)'/
  pattern_regex = /with pattern '([^']*)'/
  args = args.values_at(0, 2).flatten
  args.each do |arg|
    case arg
      when delay_regex then
        options[:delay] = arg.scan(delay_regex).first[0]
      when pattern_regex then
        options[:pattern] = arg.scan(pattern_regex).first[0]
    end
  end
  @response_id = $mirage.set(endpoint, options)
  puts "response id is: #{@response_id}"
end

When /^getting '(.*?)'$/ do |endpoint|
  get_response(endpoint)
end

When /^getting '(.*?)' with request body:$/ do |endpoint, request_body|
  get_response(endpoint, :body => request_body)
end

def get_response(endpoint, parameters={})
  start_time = Time.now
  @response = $mirage.get(endpoint, parameters)
  @response_time = Time.now - start_time
end

When /^getting '(.*?)' with request parameters:$/ do |endpoint, table|
  parameters = {}
  table.hashes.each do |hash|
    parameters[hash['parameter'].to_sym] = hash['value']
  end
  get_response(endpoint, parameters)
end

Then /^'(.*?)' should be returned$/ do |expected_response|
  @response.should == expected_response
end

Then /^a (404|500) should be returned$/ do |error_code|
  @response.code.should == error_code.to_i
end

When /^I clear '(.*?)' (responses|requests) from the MockServer$/ do |endpoint, thing|
  if endpoint.downcase == 'all'
    $mirage.clear
  else
    $mirage.clear(thing, endpoint)
  end
end

When /^peeking at the response for response id '(.*?)'$/ do |response_id|
  @response = $mirage.peek(response_id)
end

Given /^an attempt is made to set '(.*?)' without a response$/ do |endpoint|
  @response = $mirage.set(endpoint)
end

Then /^tracking the request should return a 404$/ do
  $mirage.check(@response_id).code.should == 404
end

Then /^the response id should be '(\d+)'$/ do |response_id|
  @response_id.should == response_id
end

Then /^'(.*?)' should have been tracked$/ do |text|
  tracked_text = $mirage.check(@response_id)

  if ["1.8.6", "1.8.7"].include?(RUBY_VERSION) && tracked_text != text
    text.length.should == tracked_text.length
    text.split('&').each { |param_value_pair| tracked_text.should =~ /#{param_value_pair}/ }
  else
    text.should == tracked_text
  end
end

Then /^'(.*?)' should have been tracked for response id '(.*?)'$/ do |text, response_id|
  $mirage.check(response_id).should == text
end

Then /^tracking the request for response id '(.*?)' should return a 404$/ do |response_id|
  $mirage.check(response_id).code.should == 404
end

Then /^it should take at least '(.*)' seconds$/ do |time|
  (@response_time).should >= time.to_f
end

When /^I (rollback|snapshot) the MockServer$/ do |action|
  case action
    when 'rollback' then
      $mirage.rollback
    when 'snapshot' then
      $mirage.snapshot
  end
end

Given /^the response for '([^']*)' is file '([^']*)'$/ do |endpoint, file_path|
  $mirage.set(endpoint, :file=>::File.new(file_path))
end

Then /^the response should be a file the same as '([^']*)'$/ do |file_path|
  @response.save_as("temp.download")
  FileUtils.cmp("temp.download", file_path).should == true
end

Then /^mirage should be running on '(.*)'$/ do |url|
  get(url).code.to_i.should == 200
end

Given /^I run '(.*)'$/ do |command|
  path = ENV['mode'] == 'regression' ? '' : "#{::File.dirname(__FILE__)}/../../bin/"
  @commandline_output = normalise(IO.popen("export RUBYOPT='' && #{path}#{command}").read)
end

Given /^Mirage is not running$/ do
  stop_mirage if $mirage.running?
end

Given /^Mirage is running$/ do
  start_mirage unless $mirage.running?
end

Then /^Connection should be refused to '(.*)'$/ do |url|

  begin
    get(url)
    fail "Mirage is still running"
  rescue Errno::ECONNREFUSED
  end

end

Given /^the file '(.*)' contains:$/ do |file_path, content|
  FileUtils.rm_rf(file_path) if ::File.exists?(file_path)
  directory = ::File.dirname(file_path)
  FileUtils.mkdir_p(directory)
  file = ::File.new("#{directory}/#{::File.basename(file_path)}", 'w')
  file.write(content)
  file.close
end

When /^reloading the defaults$/ do
  $mirage.load_defaults
end

def normalise text
  text.gsub(/[\n]/, ' ').gsub(/\s+/, ' ')
end

Then /^the usage information should be displayed$/ do
  @usage.each { |line| @commandline_output.should =~ /#{line}/ }
end
Given /^usage information:$/ do |table|
  @usage = table.raw.flatten.collect { |line| normalise(line) }
end

Then /^run$/ do |text|
  text.gsub!("\"", "\\\\\"")
  raise "run failed" unless system "ruby -e \"#{@code_snippet}\n#{text}\""
end

Given /^the following code snippet is included when running code:$/ do |text|
  @code_snippet = text.gsub("\"", "\\\\\"")
end

When /^I hit '(http:\/\/localhost:7001\/mirage\/(.*?))'$/ do |url, response_id|
  start_time = Time.now
  @response = http_get(url)
  @response_time = Time.now - start_time
end
#Given /^I hit '(http:\/\/localhost:7001\/mirage\/set\/(.*?))' with parameters:?$/ do |url, endpoint, parameters|
#  http_post(url)
#end
When /^I hit '(http:\/\/localhost:7001\/mirage\/(.*?))' with parameters:$/ do |url, endpoint, table|
  parameters = {}
  table.raw.each { |row| parameters[row[0].to_sym]=row[1] }

#  puts "parameters are: #{parameters}"
  @response_id = http_get(url, parameters)
#  puts "hello"
end