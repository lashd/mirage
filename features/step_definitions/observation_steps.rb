Then /^'([^']*)' should be returned$/ do |expected_response|
  response_text = last_response.body
  if response_text != expected_response
    expected_response.split('&').each {|param_value_pair| expect(response_text).to include(/#{param_value_pair}/)}
    expect(expected_response.length).to eq(response_text.length)
  end
end

Then /^a (\d+) should be returned$/ do |error_code|
  expect(last_response.code.to_i).to eq(error_code.to_i)
end

Then /^it should take at least '(.*)' seconds$/ do |time|
  expect(response_time).to be >= time.to_f
end

Then /^mirage (should|should not) be running on '(.*)'$/ do |should, url|
  running = begin
    expect(get(url).code.to_i).to eq(200)
  rescue Exception => e
    false
  end

  if should == "should"
    expect(running).to eq(true)
  else
    expect(running).to eq(false)
  end
end

Given /^Mirage (is|is not) running$/ do |running|
  if running == 'is'
    start_mirage_in_scratch_dir unless Mirage.running?
  else
    Mirage.stop :all
  end
end

Then /^the usage information should be displayed$/ do
  @usage.each_line {|line| expect(commandline_output).to include(line)}
end

Then /^I should see '(.*?)' on the command line$/ do |content|
  expect(commandline_output).to include(content)
end

Then /^'(.*)' should exist$/ do |path|
  expect(File.exists?("#{SCRATCH}/#{path}")).to eq(true)
end

Then /^mirage.log should contain '(.*)'$/ do |content|
  log_file_content = @mirage_log_file.readlines.to_s
  fail("#{content} not found in mirage.log: #{log_file_content}") unless log_file_content.index(content)
end

When /^the response '([^']*)' should be '([^']*)'$/ do |header, value|
  expect(last_response.response[header]).to include(value)
end

Then /^request data should have been retrieved$/ do
  request_data = JSON.parse(last_response.body)
  expect(request_data).to be_a(Array)
  expect(request_data.size).to eq(1)
  request_data = request_data.first
  expect(request_data.include?('parameters')).to eq(true)
  expect(request_data.include?('headers')).to eq(true)
  expect(request_data.include?('body')).to eq(true)
  expect(request_data.include?('request_url')).to eq(true)
  expect(request_data.include?('id')).to eq(true)
end

Then(/^the template (request|response) specification should have the following set:$/) do |spec, table|
  template_json = JSON.parse(get("http://localhost:7001/templates/#{JSON.parse(last_response.body)['id']}").body)
  request_specification = template_json[spec]
  expect(request_specification.size).to eq(table.hashes.size)
  table.hashes.each do |hash|
    default = request_specification[hash['Setting'].downcase.gsub(' ', '_')]
    case required_default = hash['Default']
      when 'none'
        case default
          when Array
            expect(default).to eq([])
          when Hash
            expect(default).to eq({})
          else
            expect(default).to eq("")

        end
      else
        expect(default.to_s.downcase).to eq(required_default.downcase)
    end
  end
end

Then(/^the following json should be returned:$/) do |text|
  expect(JSON(text)).to eq(JSON(last_response.body))
end

When(/^the content-type should be '(.*)'$/) do |content_type|
  expect(last_response.content_type).to eq(content_type)
end

Then(/^there should be '(\d+)' request tracked$/) do |count|
  requests = JSON(last_response.body)
  expect(requests.size).to eq(count)
end