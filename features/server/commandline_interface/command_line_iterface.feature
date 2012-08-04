@command_line
Feature: Mirage is started from the command line.
  Mirage logs to mirage.log at the path where Mirage is started from


  Background: Mirage usage
    Given usage information:
      | Usage: mirage start\|stop [options] |
      | -p, --port PORT                     |
      | -d, --defaults DIR                  |


  Scenario: Starting with help option
    Given I run 'mirage --help'
    Then the usage information should be displayed