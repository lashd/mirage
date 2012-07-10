@command_line
Feature: The Mirage client provides a programmatic interface equivalent to the command line interface. This gives an
  easy method for bringing mirage up in situ inside a test suite.


  Scenario: Starting mirage with defaults
    Given I run
    """
    Mirage.start
    """
    Then mirage should be running on 'http://localhost:7001/mirage'