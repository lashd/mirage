Feature: Inspecting Templates

  The client can be used to retrieve a template stored on Mirage.

  Background:
    Given the following require statements are needed:
    """
    require 'rubygems'
    require 'rspec/expectations'
    require 'mirage/client'
    include RSpec::Matchers
    """

  Scenario: retrieving a Template
    Given a template for 'greeting' has been set with a value of 'Hello'

    When I run
    """
      expect(Mirage::Client.new.templates(1).body).to eq('Hello')
    """

    When GET is sent to '/requests/1'
    Then the following json should be returned:
    """
      []
    """

  Scenario: retrieving a Template that does not exist
    Given I run
    """
    begin
      expect(Mirage::Client.new.templates(2)).to eq('this should not have happened')
      fail("Error should have been thrown")
    rescue Exception => e
      expect(e).to be_a(Mirage::TemplateNotFound)
    end
    """