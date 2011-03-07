@command_line
Feature: Mirage can be started and preloaded with a number of default responses.
  Usage: put defaults in to


  Scenario: Mirage started with responses in the default location
    Given the file 'defaults/default_greetings.rb' contains:
    """
    Mirage.default do |mirage|
      mirage.set('greeting', :response => 'hello')
      mirage.set('leaving', :response => 'goodbye')
    end
    """
    And I run 'mirage start'
    When getting 'greeting'
    Then 'hello' should be returned
    When getting 'leaving'
    Then 'goodbye' should be returned


  Scenario: Mirage started specifying default responses location
    Given the file 'custom_default_location/default_greetings.rb' contains:
    """
    Mirage.default do |mirage|
      mirage.set('greeting', :response => 'hello')
    end
    """
    And I run 'mirage start -d ./custom_default_location'
    When getting 'greeting'
    Then 'hello' should be returned


  Scenario: Mirage started specifying a custom default location
    Given the file 'custom_default_location/default_greetings.rb' contains:
    """
    Mirage.default do |mirage|
      mirage.set('greeting', :response => 'hello')
    end
    """
    And I run 'mirage start -d ./custom_default_location'
    When reloading the defaults
    And getting 'greeting'
    Then 'hello' should be returned


  Scenario: The state of Mirage is change and the the defaults are reloaded
    Given the file 'defaults/default_greetings.rb' contains:
    """
    Mirage.default do |mirage|
      mirage.set('greeting', :response => 'hello')
    end
    """
    And I run 'mirage start'
    And I clear 'all' responses from the MockServer
    And the response for 'a_new_response' is:
    """
    new response
    """
    When reloading the defaults
    When getting 'greeting'
    Then 'hello' should be returned
    When getting 'a_new_response'
    Then a 404 should be returned



