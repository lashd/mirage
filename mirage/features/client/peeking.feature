Feature: the client can be used for peeking at responses hosted on Mirage.

  Background:
    Given the following gems are required to run the Mirage client test code:
    """
    require 'rubygems'
    require 'rspec'
    require 'mirage'
    """

  Scenario: peeking a response
    Given I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Hello |

    When I run
    """
      Mirage::Client.new.peek(1).should == 'Hello'
    """

    When I hit 'http://localhost:7001/mirage/query/1'
    Then a 404 should be returned

  Scenario: getting a response that does not exist
    Given I run
    """
    begin
      Mirage::Client.new.peek(2).should == 'this should not have happened'
      fail("Error should have been thrown")
    rescue Exception => e
      e.is_a?(Mirage::ResponseNotFound).should == true
    end
    """