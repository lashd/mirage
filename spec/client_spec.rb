require 'spec_helper'
require 'mirage/client'



describe Mirage::Client do
  include Mirage

  before :each do
    @response = mock('response').as_null_object
  end


  it 'is configured to connect to local host port 7001 by default' do
    client = Client.new
    client.should_receive(:http_put).with(/localhost:7001/, anything, anything).and_return(@response)
    client.put "greeting", "hello"
  end

  it 'can be configured with a url pointing to Mirage' do
    url = "http://url.for.mirage"
    client = Client.new url
    client.should_receive(:http_put).with(/#{url}/, anything, anything).and_return(@response)
    client.put "greeting", "hello"
  end

  it 'can be configured with a port refering to which port Mirage is running on on localhost' do
    port = 9001
    client = Client.new :port => port
    client.should_receive(:http_put).with(/localhost:#{port}/, anything, anything).and_return(@response)
    client.put "greeting", "hello"
  end

  it 'raises an error if neither a port or url specified in the argument' do
    expect{Client.new({})}.should raise_error()
    expect{Client.new("rubbish")}.should raise_error()
  end
end
