Given /^I run '(.*)'$/ do |command|
  run(command)
end

Given /^the file '(.*)' contains:$/ do |file_path, content|
  write_to_file file_path, content
end

Given /^usage information:$/ do |usage|
  @usage = normalise(usage.to_s)
end

Then /^I run$/ do |code|
  raise "run failed" unless run_ruby(code)
end

Given /^the following require statements are needed:$/ do |text|
  @code_snippet = escape_double_quotes(text)
end

When /^I send (POST|PUT) to '(.*)' with request entity$/ do |method, endpoint, entity|
  url = "http://localhost:7001#{endpoint}"
  send(method.downcase, url, body: entity)
end

When /^(GET|PUT|POST|DELETE) is sent to '([^']*)'$/ do |method, endpoint|
  send(method.downcase, "http://localhost:7001#{endpoint}")
end

When /^I send (GET|POST) to '(.*)' with parameters:$/ do |http_method, endpoint, table|

  url = "http://localhost:7001#{endpoint}"
  parameters = {}
  table.raw.each do |row|
    parameter, value = row[0].to_sym, row[1]
    value = File.exists?(value) ? File.open(value, 'rb') : value
    parameters[parameter]=value
  end

  send(http_method.downcase, url, query: parameters, headers: {'Content-length' => '0'})
end

Given /^the following template template:$/ do |text|
  @response_template = Mirage::Hashie::Mash.new(JSON.parse(text))
end

When /^'(.*)' is base64 encoded$/ do |template_component|
  @response_template.send(:eval, "#{template_component}=Base64.encode64(#{template_component})")
end

When /^the template is sent using PUT to '(.*?)'$/ do |endpoint|
  put("http://localhost:7001#{endpoint}",
                  body: @response_template.to_hash.to_json,
                  headers: {"Content-Type" => "application/json"})
end

Given /^a template for '(.*)' has been set with a value of '(.*)'$/ do |endpoint, value|
  mirage.templates.put(endpoint, value)
end

Given(/^the following Template JSON:$/) do |text|
  @response_template = Mirage::Hashie::Mash.new(JSON.parse(text))
end