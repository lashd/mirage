Before('@command_line') do
  stop_mirage
end

After('@command_line') do
  stop_mirage
end

Then /^'([^']*)' should be returned$/ do |expected_response|
  response_text = @response.body
  if response_text != expected_response
    expected_response.split('&').each { |param_value_pair| response_text.should =~ /#{param_value_pair}/ }
    expected_response.length.should == response_text.length
  end
end

Then /^a (200|404|500) should be returned$/ do |error_code|
  @response.code.to_i.should == error_code.to_i
end

Then /^it should take at least '(.*)' seconds$/ do |time|
  (@response_time).should >= time.to_f
end


Then /^the response should be a file the same as '([^']*)'$/ do |file_path|
  raise "response is not a file it's a: #{@response.class} " unless @response.instance_of?(Mechanize::File)

  download_path = "#{SCRATCH}/temp.download"
  @response.save_as(download_path)
  FileUtils.cmp(download_path, file_path).should == true
end

Then /^mirage should be running on '(.*)'$/ do |url|
  get(url).code.to_i.should == 200
end

Given /^I run '(.*)'$/ do |command|
  path = ENV['mode'] == 'regression' ? '' : "../bin/"
  @commandline_output = normalise(run("#{path}#{command}"))
end

Given /^Mirage (is|is not) running$/ do |running|
  if running == 'is'
    start_mirage unless $mirage.running?
  else
    stop_mirage if $mirage.running?
  end
end

Then /^Connection should be refused to '(.*)'$/ do |url|
  begin
    get(url)
    fail "Mirage is still running"
  rescue Errno::ECONNREFUSED
  end
end

Given /^the file '(.*)' contains:$/ do |file_path, content|
  file_path = "#{SCRATCH}/#{file_path}" unless file_path =~ /^\//

  FileUtils.rm_rf(file_path) if File.exists?(file_path)
  FileUtils.mkdir_p(File.dirname(file_path))

  file = File.new("#{file_path}", 'w')
  file.write(content)
  file.close
end

Then /^the usage information should be displayed$/ do
  @usage.each { |line| @commandline_output.should =~ /#{line}/ }
end
Given /^usage information:$/ do |table|
  @usage = table.raw.flatten.collect { |line| normalise(line) }
end

Then /^I run$/ do |text|
  text.gsub!("\"", "\\\\\"")
  raise "run failed" unless system "#{RUBY_CMD} -e \"#{@code_snippet}\n#{text}\""
end

Given /^the following gems are required to run the Mirage client test code:$/ do |text|
  @code_snippet = text.gsub("\"", "\\\\\"")
end

When /^I hit '(http:\/\/localhost:7001\/mirage\/(.*?))'$/ do |url, response_id|
  @response = hit_mirage(url)
end

When /^I post to '(http:\/\/localhost:7001\/mirage\/(.*?))'$/ do |url, operation|
  @response = http_post(url)
end

When /^I (hit|get|post to) '(http:\/\/localhost:7001\/mirage\/(.*?))' with parameters:$/ do |http_method, url, endpoint, table|

  parameters = {}
  table.raw.each do |row|
    parameter, value = row[0].to_sym, row[1]
    value = File.exists?(value) ? File.open(value, 'rb') : value
    parameters[parameter]=value
  end

  @response = hit_mirage(url, parameters)
end

When /^I send (POST|PUT) to '(http:\/\/localhost:7001\/mirage\/(.*?))' with request entity$/ do |method, url, endpoint, entity|

  @response = case method
                when 'POST'
                then
                  post(url, entity)
                when 'PUT'
                then
                  put(url, entity)
              end
end

When /^I send (GET|PUT|POST|OPTIONS|HEAD|DELETE) to '(http:\/\/localhost:7001\/mirage([^']*))'$/ do |method, url, endpoint|
  start_time = Time.now
  @response = case method
                when 'GET' then
                  get(url)
                when 'PUT' then
                  put(url, '')
                when 'POST' then
                  post(url, '')
                when 'HEAD' then
                  head(url)
                when 'OPTIONS' then
                  options(url)
                when 'DELETE' then
                  delete(url)
              end
  @response_time = Time.now - start_time
end


When /^I send PUT to '(http:\/\/localhost:7001\/mirage\/([^']*))' with body '([^']*)'$/ do |url, endpoint, body|
  start_time = Time.now
  @response = put(url, body)
  @response_time = Time.now - start_time
end

When /^I send PUT to '(http:\/\/localhost:7001\/mirage\/([^']*))' with body '([^']*)' and headers:$/ do |url, endpoint, body, table|
  headers = {}
  table.raw.each do |row|
    parameter, value = row[0], row[1]
    headers[parameter]=value
  end
  @response = put(url, body, headers)
end


When /^I hit '(http:\/\/localhost:7001\/mirage\/(.*?))' with request body:$/ do |url, endpoint, request_body|
  @response = hit_mirage(url, {:body => request_body})
end

Then /^I should see '(.*?)' on the command line$/ do |content|
  @commandline_output.should =~/#{content}/
end

Then /^'(.*)' should exist$/ do |path|
  File.exists?("#{SCRATCH}/#{path}").should == true
end

Then /^mirage.log should contain '(.*)'$/ do |content|
  log_file_content = @mirage_log_file.readlines.to_s
  fail("#{content} not found in mirage.log: #{log_file_content}") unless log_file_content.index(content)
end

Given /^I goto '(.*)'$/ do |url|
  @page = Mechanize.new.get url
end

Then /^I should see '(.*)'$/ do |text|
  @page.body.index(text).should_not == nil
end

When /^I click '(.*)'$/ do |thing|
  @page = @page.links.find { |link| link.attributes['id'] == thing }.click
end
When /^I send (GET|POST) to '(http:\/\/localhost:7001\/mirage\/(.*?))' with parameters:$/ do |http_method, url, endpoint, table|

  parameters = {}
  table.raw.each do |row|
    parameter, value = row[0].to_sym, row[1]
    value = File.exists?(value) ? File.open(value, 'rb') : value
    parameters[parameter]=value
  end

  @response = case http_method
                when 'POST' then
                  post(url, parameters)
                when 'GET' then
                  get(url, parameters)
              end
end
Then /^the following should be returned:$/ do |text|
  @response.body.should == text
end
Given /^I send PUT to '(http:\/\/localhost:7001\/mirage\/(.*?))' with file: ([^']*) and headers:$/ do |url, endpoint, path, table|
  headers = {}
  table.raw.each do |row|
    parameter, value = row[0], row[1]
    headers[parameter]=value
  end
  put(url, File.new(path), headers)
end
Then /^the response should not be a file$/ do
  @response.instance_of?(Mechanize::File).should == false
end

When /^the response '([^']*)' should be '([^']*)'$/ do |header, value|
  @response.response[header].should include(value)
end

Then /^the response should be the same as the content of '([^']*)'$/ do |path|
  @response.body.should == File.read(path)
end