require 'base64'
require 'hashie'

Then /^'([^']*)' should be returned$/ do |expected_response|
  response_text = @response.body
  if response_text != expected_response
    expected_response.split('&').each { |param_value_pair| response_text.should =~ /#{param_value_pair}/ }
    expected_response.length.should == response_text.length
  end
end

Then /^a (\d+) should be returned$/ do |error_code|
  @response.code.to_i.should == error_code.to_i
end

Then /^it should take at least '(.*)' seconds$/ do |time|
  (@response_time).should >= time.to_f
end


Then /^mirage (should|should not) be running on '(.*)'$/ do |should, url|
  running = false
  begin
    running = http_get(url).code.to_i.should == 200
  rescue
  end

  should == "should" ? running.should == true : running.should == false
end

Given /^I run '(.*)'$/ do |command|
  if ENV['mode'] == 'regression' && ChildProcess.windows?
    command.gsub!(/^mirage/, MIRAGE_CMD)
  else
    path = "#{RUBY_CMD} ../bin/"
  end

  @commandline_output = normalise(run("#{path}#{command}"))
end

Given /^Mirage (is|is not) running$/ do |running|
  if running == 'is'
    start_mirage_in_scratch_dir unless Mirage.running?
  else
    Mirage.stop :all
  end
end

Then /^Connection should be refused to '(.*)'$/ do |url|
  begin
    http_get(url)
    fail "Mirage is still running"
  rescue Errno::ECONNREFUSED
  end
end

Given /^the file '(.*)' contains:$/ do |file_path, content|
  file_path = "#{SCRATCH}/#{file_path}" unless file_path =~ /^\//

  FileUtils.rm_rf(file_path) if File.exists?(file_path)
  FileUtils.mkdir_p(File.dirname(file_path))

  File.open("#{file_path}", 'w') do |file|
    file.write(content)
  end

end

Then /^the usage information should be displayed$/ do
  @usage.each_line { |line| @commandline_output.should include(line) }
end

Given /^usage information:$/ do |usage|
  @usage = normalise(usage.to_s)
end

Then /^I run$/ do |text|
  text.gsub!("\"", "\\\\\"")
  Dir.chdir SCRATCH do
    raise "run failed" unless system "#{RUBY_CMD} -I #{SOURCE_PATH} -e \"#{@code_snippet}\n#{text}\""
  end
end

Given /^the following require statements are needed:$/ do |text|
  @code_snippet = text.gsub("\"", "\\\\\"")
end

Given /^the following gems are required to run the Mirage client test code:$/ do |text|
  @code_snippet = text.gsub("\"", "\\\\\"")
end

When /^I send (POST|PUT) to '(.*)' with request entity$/ do |method, endpoint, entity|
  url = "http://localhost:7001#{endpoint}"
  @response = case method
                when 'POST'
                then
                  http_post(url, entity)
                when 'PUT'
                then
                  http_put(url, entity)
              end
end

When /^(GET|PUT|POST|OPTIONS|HEAD|DELETE) is sent to '([^']*)'$/ do |method, endpoint|
  start_time = Time.now
  url = "http://localhost:7001#{endpoint}"
  @response = case method
                when 'GET' then
                  http_get(url)
                when 'PUT' then
                  http_put(url, '')
                when 'POST' then
                  http_post(url, '')
                when 'HEAD' then
                  http_head(url)
                when 'OPTIONS' then
                  http_options(url)
                when 'DELETE' then
                  http_delete(url)
              end
  @response_time = Time.now - start_time
end


When /^I send (PUT|POST) to '(.*)' with body '(.*)'$/ do |method, endpoint, body|
  url = "http://localhost:7001#{endpoint}"
  start_time = Time.now
  @response = case method
                when 'PUT'
                  http_put(url, body)
                when 'POST'
                  http_post(url, body)
              end

  @response_time = Time.now - start_time
end

When /^I send PUT to '(.*)' with body '([^']*)' and headers:$/ do |endpoint, body, table|
  url = "http://localhost:7001#{endpoint}"
  headers = {}
  table.raw.each do |row|
    parameter, value = row[0], row[1]
    headers[parameter]=value
  end
  @response = http_put(url, body, :headers => headers)
end

Then /^I should see '(.*?)' on the command line$/ do |content|
  @commandline_output.should include(content)
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

When /^I send (GET|POST) to '(.*)' with parameters:$/ do |http_method, endpoint, table|


  url = "http://localhost:7001#{endpoint}"
  parameters = {}
  table.raw.each do |row|
    parameter, value = row[0].to_sym, row[1]
    value = File.exists?(value) ? File.open(value, 'rb') : value
    parameters[parameter]=value
  end

  @response = case http_method
                when 'POST' then
                  http_post(url, parameters)
                when 'GET' then
                  http_get(url, parameters)
              end
end

Then /^the following should be returned:$/ do |text|
  text.gsub("\n","").gsub(" ", "").should == @response.body
end

Given /^I send PUT to '(http:\/\/localhost:7001\/mirage\/(.*?))' with file: ([^']*) and headers:$/ do |url, endpoint, path, table|
  headers = {}
  table.raw.each do |row|
    parameter, value = row[0], row[1]
    headers[parameter]=value
  end

  Dir.chdir SCRATCH do
    http_put(url, File.new(path), :headers => headers)
  end
end

Given /^I send PUT to '(.*?)' with body '([^']*)' and parameters:$/ do |endpoint, body, table|
  url = "http://localhost:7001#{endpoint}"
  headers = {}
  table.raw.each do |row|
    parameter, value = row[0], row[1]
    headers[parameter]=value
  end

  Dir.chdir SCRATCH do
    http_put(url, File.new("/home/team/Projects/mirage/pkg/mirage-2.1.2.gem"), :parameters => headers)
  end
end


When /^the response '([^']*)' should be '([^']*)'$/ do |header, value|
  @response.response[header].should include(value)
end

Then /^the response should be the same as the content of '([^']*)'$/ do |path|
  Dir.chdir SCRATCH do
    @response.body.should == File.read(path)
  end
end
Given /^the following template template:$/ do |text|
  @response_template = Hashie::Mash.new(JSON.parse(text))
end
When /^'(.*)' is base64 encoded$/ do |template_component|
  @response_template.send(:eval, "#{template_component}=Base64.encode64(#{template_component})")
end
When /^the template is sent using PUT to '(.*?)'$/ do |endpoint|

  @response = http_put("http://localhost:7001#{endpoint}", @response_template.to_hash.to_json, :headers => {"Content-Type" => "application/json"})
end
Given /^a template for '(.*)' has been set with a value of '(.*)'$/ do |endpoint, value|
  $mirage.templates.put(endpoint, value)
end
Then /^request data should have been retrieved$/ do
  puts @response.body
  request_data = JSON.parse(@response.body)
  request_data.include?('parameters').should == true
  request_data.include?('headers').should == true
  request_data.include?('body').should == true
  request_data.include?('request_url').should == true
end
Given(/^the following Template JSON:$/) do |text|
  @response_template = Hashie::Mash.new(JSON.parse(text))
end
Then(/^the template (request|response) specification should have the following set:$/) do |spec, table|
  template_json = JSON.parse(http_get("http://localhost:7001/templates/#{JSON.parse(@response.body)['id']}").body)
  request_specification = template_json[spec]
  request_specification.size.should==table.hashes.size
  table.hashes.each do |hash|
    default = request_specification[hash['Setting'].downcase.gsub(' ', '_')]
    case required_default = hash['Default']
      when 'none'
        case default
          when Array
            default.should == []
          when Hash
            default.should == {}
          else
            default.should == ""

        end
      else
        default.to_s.downcase.should == required_default.downcase
    end
  end
end
Then(/^the following json should be returned:$/) do |text|
  JSON.parse(text).should == JSON.parse(@response.body)
end
When(/^the content-type should be '(.*)'$/) do |content_type|
  @response.content_type.should == content_type
end