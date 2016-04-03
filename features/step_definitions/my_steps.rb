Given /^I run '(.*)'$/ do |command|
  if ENV['mode'] == 'regression' && ChildProcess.windows?
    command.gsub!(/^mirage/, MIRAGE_CMD)
  else
    path = "#{RUBY_CMD} ../bin/"
  end

  @commandline_output = normalise(run("#{path}#{command}"))
end

Given /^the file '(.*)' contains:$/ do |file_path, content|
  write_to_file file_path, content
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

When /^I send (POST|PUT) to '(.*)' with request entity$/ do |method, endpoint, entity|
  url = "http://localhost:7001#{endpoint}"
  @response = case method
                when 'POST'
                  post(url, body: entity)
                when 'PUT'
                  put(url, body: entity)
              end
end

When /^(GET|PUT|POST|DELETE) is sent to '([^']*)'$/ do |method, endpoint|
  start_time = Time.now
  url = "http://localhost:7001#{endpoint}"
  @response = case method
                when 'GET' then
                  get(url)
                when 'PUT' then
                  put(url, body: '')
                when 'POST' then
                  post(url, body: '')
                when 'DELETE' then
                  delete(url)
              end
  @response_time = Time.now - start_time
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
                  post(url, query: parameters, headers: {'Content-length' => '0'})
                when 'GET' then
                  get(url, query: parameters)
              end
end

Given /^the following template template:$/ do |text|
  @response_template = Hashie::Mash.new(JSON.parse(text))
end

When /^'(.*)' is base64 encoded$/ do |template_component|
  @response_template.send(:eval, "#{template_component}=Base64.encode64(#{template_component})")
end

When /^the template is sent using PUT to '(.*?)'$/ do |endpoint|
  @response = put("http://localhost:7001#{endpoint}", body: @response_template.to_hash.to_json, :headers => {"Content-Type" => "application/json"})
end

Given /^a template for '(.*)' has been set with a value of '(.*)'$/ do |endpoint, value|
  mirage.templates.put(endpoint, value)
end

Given(/^the following Template JSON:$/) do |text|
  @response_template = Hashie::Mash.new(JSON.parse(text))
end