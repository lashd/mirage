require 'spec_helper'
require 'mirage/client'



describe Template::Configuration do

  it 'should have defaults' do
    configuration = Template::Configuration.new
    assert_defaults configuration
  end

  it 'should be reset' do
    configuration = Template::Configuration.new
    configuration.http_method :post
    configuration.status 202
    configuration.delay 3
    configuration.default true
    configuration.content_type "text/xml"

    configuration.reset
    assert_defaults configuration
  end

  def assert_defaults configuration
    expect(configuration.http_method).to eq(:get)
    expect(configuration.status).to eq(200)
    expect(configuration.delay).to eq(0)
    expect(configuration.default).to eq(false)
    expect(configuration.content_type).to eq("text/plain")
  end
end