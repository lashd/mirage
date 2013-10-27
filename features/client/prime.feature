Feature: Priming Mirage

  The client can be used to prime Mirage with Templates found in the templates directory that was configured when Mirage was started.

  Background:
    Given the following gems are required to run the Mirage client test code:
    """
    require 'rubygems'
    require 'rspec/expectations'
    require 'mirage/client'
    """

  Scenario: Priming Mirage
    Given Mirage is not running
    And I run 'mirage start'

    When the file 'mirage/default_greetings.rb' contains:
    """
    prime do |mirage|
      mirage.put('greeting', 'hello')
      mirage.put('leaving', 'goodbye')
    end
    """
    And I run
    """
    Mirage::Client.new.prime
    """
    And GET is sent to '/responses/greeting'
    Then 'hello' should be returned

    When GET is sent to '/responses/leaving'
    Then 'goodbye' should be returned