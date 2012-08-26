Feature: The Mirage client provides a programmatic interface equivalent to the command line interface. This gives an
  easy method for bringing a local instance of Mirage in situ inside a test suite.

  The client can only be used to stop Mirage if it is was used to start the running instance.

  Background:
    Given the following gems are required to run the Mirage client test code:
    """
    require 'rubygems'
    require 'rspec'
    require 'mirage/client'
    """


  Scenario: Stopping Mirage
    Given Mirage is not running
    When I run
    """
    Mirage.start
    Mirage.stop :port => 7001
    """
    Then Connection should be refused to 'http://localhost:7001/mirage'

  Scenario: Stopping Mirage on custom port
    Given Mirage is not running
    And I run 'mirage start -p 7001'
    And I run 'mirage start -p 9001'
    When I run
    """
    Mirage.stop :port => 9001
    """
    Then mirage should be running on 'http://localhost:7001/mirage'
    Then mirage should not be running on 'http://localhost:9001/mirage'

  Scenario: Stopping multiple instances of Mirage
    Given Mirage is not running
    And I run 'mirage start -p 7001'
    And I run 'mirage start -p 9001'
    And I run 'mirage start -p 10001'
    When I run
    """
    Mirage.stop :port => [9001,10001]
    """
    Then mirage should be running on 'http://localhost:7001/mirage'
    Then mirage should not be running on 'http://localhost:9001/mirage'
    Then mirage should not be running on 'http://localhost:10001/mirage'

  Scenario: Stopping all instances of Mirage
    Given Mirage is not running
    And I run 'mirage start -p 7001'
    And I run 'mirage start -p 9001'
    And I run 'mirage start -p 10001'
    When I run
    """
    Mirage.stop :all
    """
    Then mirage should not be running on 'http://localhost:7001/mirage'
    Then mirage should not be running on 'http://localhost:9001/mirage'
    Then mirage should not be running on 'http://localhost:10001/mirage'



  Scenario: Using client to stop mirage
    Given Mirage is not running
    And I run 'mirage start -p 7001'
    And I run 'mirage start -p 9001'
    When I run
    """
    begin
      Mirage.stop
      raise "should have errored"
    rescue Mirage::ClientError => ce
    end
    """
    Then mirage should be running on 'http://localhost:7001/mirage'
    And mirage should be running on 'http://localhost:9001/mirage'

  Scenario: Stopping Mirage without specifying the port when more than one instance of Mirage is running
    Given Mirage is not running
    When I run
    """
    client = Mirage.start
    client.stop
    """
    Then Connection should be refused to 'http://localhost:7001/mirage'