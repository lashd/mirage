@command_line
Feature: Mirage is started from the command line.
  Mirage logs to mirage.log at the path where Mirage is started from


  Background: Mirage usage
    Given usage information:
      | Tasks:                                                                                       |
      | mirage help [TASK]                           # Describe available tasks or one specific task |
#      | mirage start                                 # Starts mirage                                 |
#      | mirage stop -p, --port=[port_1 port_2\|all]  # stops mirage                                  |


  Scenario: Starting with help option
    Given I run 'mirage help'
    Then the usage information should be displayed