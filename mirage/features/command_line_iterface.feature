@command_line
Feature: Mirage can be started from the command line.

  Background: Mirage usage
    Given usage information:
      | -p, --port PORT    |
      | -d, --defaults DIR |


  Scenario: User looks for help
    Given I run 'mirage start --help'
    Then the usage information should be displayed


  Scenario: User needs help
    Given I run 'mirage start --invalid-option'
    Then the usage information should be displayed


  Scenario: User starts Mirage with no options
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


