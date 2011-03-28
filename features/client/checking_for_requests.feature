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
      | name | leon  |
    Then I run
    """
       Mirage::Client.new.check_request(1).should == 'name=leon'
    """