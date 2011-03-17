Feature: Requests made to the Mirage Server can be tracked using the Mirage client

  Background:
    Given the following gems are required to run the Mirage client test code:
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
    Then I run
    """
       Mirage::Client.new.query(1).should == 'surname=Davis&firstname=Leon'
    """