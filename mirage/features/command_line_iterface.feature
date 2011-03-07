@command_line
Feature: Mirage can be started from the command line.
  Usage:
  Start: Start the Mirage Server
  --port PORT: The port for Mirage to start on. Defaults to 7001
  --contextRoot ROOT: Defaults to '/mirage'

  Stop: Stop the Mirage Server


  Scenario: Starting Mirage
    Given Mirage is not running
    When I run 'mirage start'
    Then mirage should be running on 'http://localhost:7001/mirage'


  Scenario: Starting Mirage on a custom port
    Given Mirage is not running
    When I run 'mirage start -p 9001'
    Then mirage should be running on 'http://localhost:9001/mirage'


  Scenario: Stopping Mirage
    Given I run 'mirage start'
    When I run 'mirage stop'
    Then Connection should be refused to 'http://localhost:7001/mirage'