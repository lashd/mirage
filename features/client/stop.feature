@command_line
Feature: Stopping Mirage

  The client API can be used to stop instances of Mirage running on localhost.

  Background:
    Given the following require statements are needed:
    """
    require 'rubygems'
    require 'mirage/client'
    """

  Scenario: Stopping Mirage
    Given Mirage is running
    When I run
    """
    Mirage.stop
    """
    Then Connection should be refused to 'http://localhost:7001'


  Scenario: Stopping Mirage on custom port
    And I run 'mirage start -p 9001'
    When I run
    """
    Mirage.stop :port => 9001
    """
    Then mirage should not be running on 'http://localhost:9001'

  Scenario: Stopping multiple instances of Mirage
    Given I run 'mirage start -p 7001'
    And I run 'mirage start -p 9001'
    And I run 'mirage start -p 10001'
    When I run
    """
    Mirage.stop :port => [9001,10001]
    """
    Then mirage should be running on 'http://localhost:7001'
    Then mirage should not be running on 'http://localhost:9001'
    Then mirage should not be running on 'http://localhost:10001'


  Scenario: Stopping all instances of Mirage
    Given I run 'mirage start -p 7001'
    And I run 'mirage start -p 9001'
    And I run 'mirage start -p 10001'
    When I run
    """
    Mirage.stop :all
    """
    Then mirage should not be running on 'http://localhost:7001'
    Then mirage should not be running on 'http://localhost:9001'
    Then mirage should not be running on 'http://localhost:10001'