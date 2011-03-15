Feature: Requests made to the Mirage Server can be tracked using the Mirage client

  Background:
    Given the following code snippet is included when running code:
    """
    require 'rubygems'
    require 'rspec'
    require 'mirage'
    """

  Scenario: The MockServer returns a response
    Given I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Hello |

    When I hit 'http://localhost:7001/mirage/get/greeting' with parameters:
      | surname   | Davis |
      | firstname | Leon  |
    Then run
    """
       Mirage::Client.new.check(1).should == 'surname=Davis&firstname=Leon'
    """