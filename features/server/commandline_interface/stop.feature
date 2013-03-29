@command_line
Feature: Mirage can be stopped from the commandline
  If more than one instance of Mirage is running, you will be asked to supply the ports which represent the running instances
  of mirage that you wish to stop.

  Scenario: Stopping a single instance
    Given I run 'mirage start -p 7001'
    When I run 'mirage stop'
    Then mirage should not be running on 'http://localhost:7001/mirage'


  Scenario: Calling stop when there is more than one instance running
    Given I run 'mirage start -p 7001'
    Given I run 'mirage start -p 9001'
    When I run 'mirage stop'
    Then I should see 'Mirage is running on ports 7001, 9001. Please run mirage stop -p [PORT(s)] instead' on the command line
    And mirage should be running on 'http://localhost:7001/mirage'
    And mirage should be running on 'http://localhost:9001/mirage'


  Scenario: stopping on a single instance using the port
    Given I run 'mirage start -p 7001'
    And I run 'mirage start -p 9001'
    When I run 'mirage stop -p 7001'
    Then mirage should be running on 'http://localhost:9001/mirage'
    Then mirage should not be running on 'http://localhost:7001/mirage'

  Scenario: stop more than one instance
    Given I run 'mirage start -p 7001'
    And I run 'mirage start -p 9001'
    And I run 'mirage start -p 10001'
    When I run 'mirage stop -p 7001 9001'
    Then mirage should be running on 'http://localhost:10001/mirage'
    Then mirage should not be running on 'http://localhost:7001/mirage'
    Then mirage should not be running on 'http://localhost:9001/mirage'

  Scenario: stop all instances
    Given I run 'mirage start -p 7001'
    And I run 'mirage start -p 9001'
    When I run 'mirage stop -p all'
    Then mirage should not be running on 'http://localhost:10001/mirage'
    Then mirage should not be running on 'http://localhost:7001/mirage'
    Then mirage should not be running on 'http://localhost:9001/mirage'

