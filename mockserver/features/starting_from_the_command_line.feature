Feature: Mirage can be started from the command line.
  Usage:
  Start: Start the Mirage Server
    --port PORT: The port for Mirage to start on. Defaults to 7001
    --contextRoot ROOT: Defaults to '/mirage'

  Stop: Stop the Mirage Server

  @command_line
  Scenario: Starting Mirage
    Given I start Mirage
    Then mirage should be running on 'http://localhost:7001/mirage'