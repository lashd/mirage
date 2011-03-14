Feature: Interacting with Mirage is done via HTTP using a REST style URLs and therefor you can interact with it in any language
  that has a HTTP client. If however you are using Ruby you can use the Mirage Client that comes in the Mirage distribution.

  By default the client is configured to connect to an instance of the Mirage server on localhost:7001 which the default port that Mirage starts on.

  Background:
    Given the following code snippet is included when running code:
    """
    require 'rubygems'
    require 'rspec'
    """

  Scenario: Setting
    Given run
    """
    require 'mirage'
    Mirage::Client.new.set('greeting',:response => 'hello')
    """
    When I hit 'http://localhost:7001/mirage/get/greeting'
    Then 'hello' should be returned

  Scenario: Getting a text based response
    Given I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Hello |

    Then run
    """
      require 'mirage'
      Mirage::Client.new.get('greeting').should == 'Hello'
    """

  Scenario: Getting a file based response
    Given the response for 'some/location/download' is file 'features/resources/test.zip'
    Then run
    """
      require 'mirage'
      response = Mirage::Client.new.get('some/location/download').save_as('temp.download')
      FileUtils.cmp('features/resources/test.zip', 'temp.download').should == true
    """

  Scenario: Checking
    Given I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Hello |

    When getting 'greeting' with request body:
    """
    Hi
    """
    Then run
    """
      require 'mirage'
      Mirage::Client.new.check(1).should == 'Hi'
    """

  Scenario: Peeking
    Given I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Hello |

    Then run
    """
      require 'mirage'
      Mirage::Client.new.peek(1).should == 'Hello'
    """


  Scenario: Setting mirage defaults
    Given the file 'defaults/default_greetings.rb' contains:
    """
    Mirage.default do |mirage|
      mirage.set('greeting', :response => 'hello')
    end
    """
    When run
    """
      require 'mirage'
      Mirage::Client.new.load_defaults
    """
    And I hit 'http://localhost:7001/mirage/get/greeting'
    Then 'hello' should be returned


  Scenario: Clearing
    Given I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Hello |

    When run
    """
      require 'mirage'
      Mirage::Client.new.load_defaults
    """
    And I hit 'http://localhost:7001/mirage/get/greeting'
    Then a 404 should be returned

  Scenario: snapshotting
    Given I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Hello |

    When run
    """
      require 'mirage'
      Mirage::Client.new.snapshot
    """
    And I clear 'all' responses from the MockServer
    And I rollback the MockServer
    And I hit 'http://localhost:7001/mirage/get/greeting'
    Then 'Hello' should be returned


  Scenario: Rolling back
    Given I hit 'http://localhost:7001/mirage/set/greeting' with parameters:
      | response | Hello |

    And I snapshot the MockServer
    And I clear 'all' responses from the MockServer
    When run
    """
      require 'mirage'
      Mirage::Client.new.rollback
    """
    And I hit 'http://localhost:7001/mirage/get/greeting'
    Then 'Hello' should be returned

  Scenario: checking if mirage is running
    Given Mirage is not running
    Then run
    """
      require 'mirage'
      Mirage::Client.new.running?.should == false
    """
    Given Mirage is running
    Then run
    """
      require 'mirage'
      Mirage::Client.new.running?.should == true
    """




