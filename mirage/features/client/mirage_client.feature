Feature: Interacting with Mirage is done via HTTP using a REST style URLs and therefor you can interact with it in any language
  that has a HTTP client. If however you are using Ruby you can use the Mirage Client that comes in the Mirage distribution.

  By default the client is configured to connect to an instance of the Mirage server on localhost:7001 which the default port that Mirage starts on.

  Background:
    Given the following gems are required to run the Mirage client test code:
    """
    require 'rubygems'
    require 'rspec'
    require 'mirage'
    """

  Scenario: Setting
    Given I run
    """
    Mirage::Client.new.set('greeting',:response => 'hello')
    """
    When I hit 'http://localhost:7001/mirage/get/greeting'
    Then 'hello' should be returned

  Scenario: Getting a text based response
    Given I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Hello |

    Then I run
    """
      Mirage::Client.new.get('greeting').should == 'Hello'
    """

  Scenario: Getting a file based response

    Given I hit 'http://localhost:7001/mirage/set/some/location/download' with parameters:
      | file | features/resources/test.zip |
    Then I run
    """
      response = Mirage::Client.new.get('some/location/download').save_as('temp.download')
      FileUtils.cmp('features/resources/test.zip', 'temp.download').should == true
    """

  Scenario: Checking
    Given I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Hello |

    When I hit 'http://localhost:7001/mirage/get/greeting' with request body:
    """
    Hi
    """
    Then I run
    """
      Mirage::Client.new.check(1).should == 'Hi'
    """

  Scenario: Peeking
    Given I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Hello |

    Then I run
    """
      Mirage::Client.new.peek(1).should == 'Hello'
    """


  Scenario: Setting mirage defaults
    Given the file 'defaults/default_greetings.rb' contains:
    """
    Mirage.default do |mirage|
      mirage.set('greeting', :response => 'hello')
    end
    """
    When I run
    """
      Mirage::Client.new.load_defaults
    """
    And I hit 'http://localhost:7001/mirage/get/greeting'
    Then 'hello' should be returned


  Scenario: Clearing
    Given I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Hello |

    When I run
    """
      Mirage::Client.new.load_defaults
    """
    And I hit 'http://localhost:7001/mirage/get/greeting'
    Then a 404 should be returned

  Scenario: snapshotting
    Given I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Hello |

    When I run
    """
      Mirage::Client.new.snapshot
    """
    And I hit 'http://localhost:7001/mirage/clear'
    And I hit 'http://localhost:7001/mirage/rollback'
    And I hit 'http://localhost:7001/mirage/get/greeting'
    Then 'Hello' should be returned


  Scenario: Rolling back
    Given I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Hello |

    And I hit 'http://localhost:7001/mirage/snapshot'
    And I hit 'http://localhost:7001/mirage/clear'
    When I run
    """
      Mirage::Client.new.rollback
    """
    And I hit 'http://localhost:7001/mirage/get/greeting'
    Then 'Hello' should be returned

  Scenario: checking if mirage is running
    Given Mirage is not running
    Then I run
    """
      Mirage::Client.new.running?.should == false
    """
    Given Mirage is running
    Then I run
    """
      Mirage::Client.new.running?.should == true
    """