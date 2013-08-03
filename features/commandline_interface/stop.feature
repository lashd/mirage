@command_line
Feature: Stopping Mirage
  Mirage can be stopped from the commandline
  If more than one instance of Mirage is running, you will be asked to supply the ports which represent the running instances
  of mirage that you wish to stop.

  Scenario: Stopping a single instance of Mirage
    Given I run 'mirage start -p 7001'
    When I run 'mirage stop'
    Then mirage should not be running on 'http://localhost:7001'

  Scenario: Stopping an instance running on a given port
    Given I run 'mirage start -p 7001'
    And I run 'mirage start -p 9001'
    When I run 'mirage stop -p 7001'
    Then mirage should be running on 'http://localhost:9001'
    Then mirage should not be running on 'http://localhost:7001'

  Scenario: Stopping more than one instance
    Given I run 'mirage start -p 7001'
    And I run 'mirage start -p 9001'
    And I run 'mirage start -p 10001'
    When I run 'mirage stop -p 7001 9001'
    Then mirage should be running on 'http://localhost:10001'
    Then mirage should not be running on 'http://localhost:7001'
    Then mirage should not be running on 'http://localhost:9001'

  Scenario: Stopping all running instances
    Given I run 'mirage start -p 7001'
    And I run 'mirage start -p 9001'
    When I run 'mirage stop -p all'
    Then mirage should not be running on 'http://localhost:10001'
    Then mirage should not be running on 'http://localhost:7001'
    Then mirage should not be running on 'http://localhost:9001'

  Scenario: Calling stop when there is more than one instance running
    Given I run 'mirage start -p 7001'
    Given I run 'mirage start -p 9001'
    When I run 'mirage stop'
    Then I should see 'Mirage is running on ports 7001, 9001. Please run mirage stop -p [PORT(s)] instead' on the command line
    And mirage should be running on 'http://localhost:7001'
    And mirage should be running on 'http://localhost:9001'
