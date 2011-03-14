Feature: the client can be used for peeking at responses hosted on Mirage.
  Background:
    Given the following code snippet is included when running code:
    """
    require 'rubygems'
    require 'rspec'
    require 'mirage'
    """

  Scenario: peeking a response
    Given the response for 'greeting' is:
      """
      Hello
      """
    Then run
    """
      Mirage::Client.new.peek(1).should == 'Hello'
    """
    And tracking the request for response id '1' should return a 404