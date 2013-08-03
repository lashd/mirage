Feature: The Mirage client can be used to snaphsot and rollback the Mirage server


  Background:
    Given the following gems are required to run the Mirage client test code:
    """
    require 'rubygems'
    require 'rspec'
    require 'mirage/client'
    """
    And I send PUT to '/templates/greeting' with request entity
    """
    The default greeting
    """


  Scenario: saving and reverting
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
    And I send GET to '/responses/leaving'
    Then a 404 should be returned

    When I send GET to '/responses/greeting'
    Then 'The default greeting' should be returned