@command_line
Feature: Help
  Mirage is started from the command line. Mirage logs to mirage.log at the path where Mirage is started from.


  Background: Mirage usage
    Given usage information:
    """
      Commands:
      mirage help [COMMAND]  # Describe available commands or one specific command
      mirage start           # Starts mirage
      mirage stop            # Stops mirage
    """


  Scenario: Starting with help option
    Given I run 'mirage help'
    Then the usage information should be displayed