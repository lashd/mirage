Feature: Inspecting Templates

  Background:
    Given the following gems are required to run the Mirage client test code:
    """
    require 'rubygems'
    require 'rspec'
    require 'mirage/client'
    """

  Scenario: peeking a template
    Given a template for 'greeting' has been set with a value of 'Hello'

    When I run
    """
      Mirage::Client.new.templates(1).body.should == 'Hello'
    """

    When GET is sent to '/requests/1'
    Then a 404 should be returned

  Scenario: getting a template that does not exist
    Given I run
    """
    begin
      Mirage::Client.new.templates(2).should == 'this should not have happened'
      fail("Error should have been thrown")
    rescue Exception => e
    puts e
      e.is_a?(Mirage::ResponseNotFound).should == true
    end
    """