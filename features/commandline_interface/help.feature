@command_line
Feature: Help
  Mirage is started from the command line. Mirage logs to mirage.log at the path where Mirage is started from.


  Background: Mirage usage
    Given usage information:
    """
      mirage help [TASK]  # Describe available tasks or one specific task
      mirage start        # Starts mirage
      mirage stop         # Stops mirage
    """


  Scenario: Starting with help option
    Given I run 'mirage help'
    Then the usage information should be displayed