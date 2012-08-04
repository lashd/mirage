Feature: stop


  Scenario: stopping on a single instance
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

