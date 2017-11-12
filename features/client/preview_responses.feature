Feature: Inspecting Templates

  The client can be used to retrieve a template stored on Mirage.

  Background:
    Given the following require statements are needed:
    """
    require 'rubygems'
    require 'rspec/expectations'
    require 'mirage/client'
    """

  Scenario: retrieving a Template
    Given a template for 'greeting' has been set with a value of 'Hello'

    When I run
    """
      Mirage::Client.new.templates(1).body.should == 'Hello'
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
      Mirage::Client.new.templates(2).should == 'this should not have happened'
      fail("Error should have been thrown")
    rescue Exception => e
      e.is_a?(Mirage::TemplateNotFound).should == true
    end
    """