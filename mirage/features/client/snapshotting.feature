Feature: The Mirage client can be used to snaphsot and rollback the Mirage server


  Background:
    Given the following code snippet is included when running code:
    """
    require 'rubygems'
    require 'rspec'
    require 'mirage'
    """
    And the response for 'greeting' is:
    """
    The default greeting
    """

  Scenario: Taking a snapshot and rolling it back
    Given run
    """
    Mirage::Client.new.snapshot
    """
    And the response for 'leaving' is:
    """
    Goodye
    """
    And the response for 'greeting' is:
    """
    Changed
    """
    Given run
    """
    Mirage::Client.new.rollback
    """
    When getting 'leaving'
    Then a 404 should be returned
    When getting 'greeting'
    Then 'The default greeting' should be returned