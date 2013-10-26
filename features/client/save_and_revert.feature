Feature: Creating snapshots

  The client can be used to snapshot and rollback the Mirage server


  Background:
    Given the following gems are required to run the Mirage client test code:
    """
    require 'rubygems'
    require 'rspec'
    require 'mirage/client'
    """
    And a template for 'greeting' has been set with a value of 'The default greeting'


  Scenario: Creating a snapshot and rolling back
    Given I run
    """
    Mirage::Client.new.save
    """
    And I send PUT to '/templates/leaving' with request entity
    """
    Goodbye
    """

    And I send PUT to '/templates/greeting' with request entity
    """
    Changed
    """

    When I run
    """
    Mirage::Client.new.revert
    """
    And GET is sent to '/responses/leaving'
    Then a 404 should be returned

    When GET is sent to '/responses/greeting'
    Then 'The default greeting' should be returned