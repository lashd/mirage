@command_line
Feature: Starting Mirage
  Mirage is started from the command line. more than instance of Mirage can be started on different ports at the same time.

  By default mirage runs on port 7001.


  Scenario: Starting mirage
    Given Mirage is not running
    When I run 'mirage start'
    Then mirage should be running on 'http://localhost:7001/mirage'
    And 'mirage.log' should exist


  Scenario: Starting Mirage on a custom port
    Given Mirage is not running
    When I run 'mirage start -p 9001'
    Then mirage should be running on 'http://localhost:9001/mirage'
