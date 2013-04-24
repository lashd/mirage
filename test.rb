require './lib/mirage/client'

class ServiceNowResponse
  extend Mirage::Template::Model

  endpoint 'service_now'

  builder_methods :this,:that

  def value
    "my value : #{this}, #{that}"
  end
end

Mirage.stop
mirage = Mirage.start
mirage.put ServiceNowResponse.new.this('foo').that('bar')
mirage.put ServiceNowResponse.new.this('foo').that('bar').required_body_content(%w(hello world))
