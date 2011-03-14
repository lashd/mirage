Feature: Requests made to the Mirage Server can be tracked using the Mirage client
  Background:
    Given the following code snippet is included when running code:
    """
    require 'rubygems'
    require 'rspec'
    require 'mirage'
    """

  Scenario: The MockServer returns a response
    Given the response for 'greeting' is:
    """
    Hello
    """
    When getting 'greeting' with request parameters:
      | parameter | value |
      | surname   | Davis |
      | firstname | Leon  |
    Then run
    """
       Mirage::Client.new.check(1).should == 'surname=Davis&firstname=Leon'
    """