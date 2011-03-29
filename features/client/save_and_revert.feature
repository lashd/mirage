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


  Scenario: saving and reverting
    Given I run
    """
    Mirage::Client.new.save
    """
    And I hit 'http://localhost:7001/mirage/set/leaving' with parameters:
      | response | Goodye |

    And I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Changed |

    When I run
    """
    Mirage::Client.new.revert
    """
    And I hit 'http://localhost:7001/mirage/get/leaving'
    Then a 404 should be returned

    When I hit 'http://localhost:7001/mirage/get/greeting'
    Then 'The default greeting' should be returned