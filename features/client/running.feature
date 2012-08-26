@command_line
Feature: Use the mirage client api to check if Mirage is running either on the local machine or on a remote host.


  Background:
    Given the following gems are required to run the Mirage client test code:
    """
    require 'rubygems'
    require 'rspec'
    require 'mirage/client'
    """


  Scenario: Check if mirage is running on the local machine on the default port
    Given Mirage is not running
    Then I run
    """
      Mirage.running?.should == false
    """
    Given Mirage is running
    Then I run
    """
      Mirage.running?.should == true
    """


  Scenario: Check if mirage is running on the local machine on a non standard port
    Given I run 'mirage start -p 9001'
    Then I run
    """
      Mirage.running?(:port => 9001).should == true
    """


  Scenario: Checking if mirage is running on remote machine
    Given I run 'mirage start -p 9001'
    Then I run
    """
      Mirage.running? "http://localhost:9001/mirage"
    """


  Scenario: Check if mirage is running using the client directly
    Given I run 'mirage start -p 9001'
    Then I run
    """
      client = Mirage::Client.new "http://localhost:9001/mirage"
      client.running?.should == true
    """
