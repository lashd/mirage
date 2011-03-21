Feature: The Mirage client can be used to snaphsot and rollback the Mirage server


  Background:
    Given the following gems are required to run the Mirage client test code:
    """
    require 'rubygems'
    require 'rspec'
    require 'mirage'
    """
    And I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | The default greeting |


  Scenario: Taking a snapshot and rolling it back
    Given I run
    """
    Mirage::Client.new.snapshot
    """
    And I hit 'http://localhost:7001/mirage/set/leaving' with parameters:
      | response | Goodye |

    And I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Changed |

    When I run
    """
    Mirage::Client.new.rollback
    """
    And I hit 'http://localhost:7001/mirage/get/leaving'
    Then a 404 should be returned

    When I hit 'http://localhost:7001/mirage/get/greeting'
    Then 'The default greeting' should be returned