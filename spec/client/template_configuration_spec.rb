require 'spec_helper'
require 'mirage/client'



describe Mirage::TemplateConfiguration do
  TemplateConfiguration = Mirage::TemplateConfiguration
  it 'should have defaults' do
    configuration = TemplateConfiguration.new
    assert_defaults configuration
  end

  it 'should be reset' do
    configuration = TemplateConfiguration.new
    configuration.http_method = :post
    configuration.status = 202
    configuration.delay = 3
    configuration.default = true
    configuration.content_type = "text/xml"

    configuration.reset
    assert_defaults configuration
  end

  def assert_defaults configuration
    configuration.http_method.should == :get
    configuration.status.should == 200
    configuration.delay.should == 0
    configuration.default.should == false
    configuration.content_type.should == "text/plain"
  end
end