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
  running = begin
    get(url).code.to_i.should == 200
  rescue
    false
  end

  should == "should" ? running.should == true : running.should == false
end

Given /^Mirage (is|is not) running$/ do |running|
  if running == 'is'
    start_mirage_in_scratch_dir unless Mirage.running?
  else
    Mirage.stop :all
  end
end

Then /^the usage information should be displayed$/ do
  @usage.each_line { |line| @commandline_output.should include(line) }
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

When /^the response '([^']*)' should be '([^']*)'$/ do |header, value|
  @response.response[header].should include(value)
end

Then /^request data should have been retrieved$/ do
  request_data = JSON.parse(@response.body)
  request_data.include?('parameters').should == true
  request_data.include?('headers').should == true
  request_data.include?('body').should == true
  request_data.include?('request_url').should == true
  request_data.include?('id').should == true
end

Then(/^the template (request|response) specification should have the following set:$/) do |spec, table|
  template_json = JSON.parse(get("http://localhost:7001/templates/#{JSON.parse(@response.body)['id']}").body)
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