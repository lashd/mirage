@command_line
Feature: Mirage is started from the command line.
  more than instance of Mirage can be started on different ports at the same time.


  Scenario: Starting mirage
    Given Mirage is not running
    When I run 'mirage start'
    Then mirage should be running on 'http://localhost:7001/mirage'
    And 'mirage.log' should exist


  Scenario: Starting Mirage on a custom port
    Given Mirage is not running
    When I run 'mirage start -p 9001'
    Then mirage should be running on 'http://localhost:9001/mirage'


  Scenario: Starting multiple instances of Mirage
    Given Mirage is not running
    When I run 'mirage start -p 7001'
    And I run 'mirage start -p 9001'
    Then mirage should be running on 'http://localhost:7001/mirage'
    And mirage should be running on 'http://localhost:9001/mirage'


  Scenario: Starting Mirage when it is already running
    Given Mirage is running
    When I run 'mirage start -p 7001'
    Then I should see 'Mirage is already running' on the command line
    Then Connection should be refused to 'http://localhost:9001/mirage'