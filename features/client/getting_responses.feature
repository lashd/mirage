Feature: the Mirage client provides a method for getting responses
  There is no need to escape any parameters before using the client api as this is done for you.

  Background:
    Given the following gems are required to run the Mirage client test code:
    """
    require 'rubygems'
    require 'rspec'
    require 'mirage'
    """
    And I post to 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | hello |

  Scenario: getting a response
    Given I run
    """
    Mirage::Client.new.get('greeting').should == 'hello'
    """

  Scenario: getting a response that does not exist
    Given I run
    """
    begin
      Mirage::Client.new.get('response_that_does_not_exits').should == 'hello'
      fail("Error should have been thrown")
    rescue Exception => e
      e.is_a?(Mirage::ResponseNotFound).should == true
    end
    """

