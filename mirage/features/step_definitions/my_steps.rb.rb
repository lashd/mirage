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


When /^I hit '(http:\/\/localhost:7001\/mirage\/(.*?))' with request body:$/ do |url, endpoint, request_body|
  start_time = Time.now
  @response = http_get(url, {:body => request_body})
  @response_time = Time.now - start_time
end


Then /^'(.*?)' should be returned$/ do |expected_response|
  if ["1.8.6", "1.8.7"].include?(RUBY_VERSION) && @response != expected_response
    expected_response.length.should == @response.length
    expected_response.split('&').each { |param_value_pair| @response.should =~ /#{param_value_pair}/ }
  else
    expected_response.should == @response
  end
  @response.should == expected_response
end

Then /^a (404|500) should be returned$/ do |error_code|
  @response.code.should == error_code.to_i
end

Then /^the response id should be '(\d+)'$/ do |response_id|
  @response_id.should == response_id
end

Then /^it should take at least '(.*)' seconds$/ do |time|
  (@response_time).should >= time.to_f
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

When /^I hit '(http:\/\/localhost:7001\/mirage\/(.*?))' with parameters:$/ do |url, endpoint, table|

  parameters = {}
  table.raw.each do |row|
    parameter, value = row[0].to_sym, row[1]

    puts "parameter is: #{parameter}"
    puts "value is: #{value}"
    value = parameter == :file ? ::File.open(value) : value
    parameters[parameter.to_sym]=value
  end

  if parameters.include? :file
    @response_id = http_post(url, parameters)
  else
    @response_id = http_get(url, parameters)
  end
  @response = @response_id
end