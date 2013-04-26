require './lib/mirage/client'
#
#class ServiceNowResponse
#  extend Mirage::Template::Model
#
#  endpoint 'service_now'
#
#  builder_methods :this,:that
#
#  def value
#    "my value : #{this}, #{that}"
#  end
#end
#
Mirage.stop
mirage = Mirage.start
#mirage.put ServiceNowResponse.new.this('foo').that('bar')
#mirage.put ServiceNowResponse.new.this('foo').that('bar').required_body_content(%w(hello world))
#mirage.put ServiceNowResponse.new.this('foo').that('bar').required_parameters({:name => 'leon'})

require 'ostruct'
class UserServiceProfile
  extend Mirage::Template::Model

  endpoint 'Users'

  def initialize persona
    super
    required_parameters[:token] = persona.token
    @persona = persona
  end

  def value
    {name: @persona.name}.to_json
  end
end

leon = OpenStruct.new(
    :name => 'leon',
    :token => '1234'
)

mirage.clear


leons_user_profile = UserServiceProfile.new leon
mirage.put leons_user_profile do
  status 404
  method :get
end
