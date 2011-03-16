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
    When I hit 'http://localhost:7001/mirage/get/greeting'
    Then 'hello' should be returned
    When I hit 'http://localhost:7001/mirage/get/leaving'
    Then 'goodbye' should be returned


  Scenario: Mirage started specifying default responses location
    Given the file 'custom_default_location/default_greetings.rb' contains:
    """
    Mirage.default do |mirage|
      mirage.set('greeting', :response => 'hello')
    end
    """
    And I run 'mirage start -d ./custom_default_location'
    When I hit 'http://localhost:7001/mirage/get/greeting'
    Then 'hello' should be returned


  Scenario: Mirage started specifying a custom default location using a relative path
    Given the file 'custom_default_location/default_greetings.rb' contains:
    """
    Mirage.default do |mirage|
      mirage.set('greeting', :response => 'hello')
    end
    """
    And I run 'mirage start -d ./custom_default_location'
    When I hit 'http://localhost:7001/mirage/load_defaults'
    And I hit 'http://localhost:7001/mirage/get/greeting'
    Then 'hello' should be returned


  Scenario: Mirage started specifying a custom default location using a full path
    Given the file '/tmp/defaults/default_greetings.rb' contains:
    """
    Mirage.default do |mirage|
      mirage.set('greeting', :response => 'hello')
    end
    """
    And I run 'mirage start -d /tmp/defaults'
    When I hit 'http://localhost:7001/mirage/load_defaults'
    And I hit 'http://localhost:7001/mirage/get/greeting'
    Then 'hello' should be returned


  Scenario: The state of Mirage is change and the the defaults are reloaded
    Given the file 'defaults/default_greetings.rb' contains:
    """
    Mirage.default do |mirage|
      mirage.set('greeting', :response => 'hello')
    end
    """
    And I run 'mirage start'
    And I hit 'http://localhost:7001/mirage/clear'
    And I hit 'http://localhost:7001/mirage/set/a_new_response' with parameters:
      | response | new response |

    When I hit 'http://localhost:7001/mirage/load_defaults'
    When I hit 'http://localhost:7001/mirage/get/greeting'
    Then 'hello' should be returned
    When I hit 'http://localhost:7001/mirage/get/a_new_response'
    Then a 404 should be returned


  Scenario: starting mirage and having a file in the defaults directory that has a mistake in it
    Given the file 'defaults/default_greetings.rb' contains:
    """
    A file with a mistake in it
    """
    When I run 'mirage start'
    Then I should see 'WARN: Unable to load default responses from: defaults/default_greetings.rb' on the command line


  Scenario: loading a default response file, that has a mistake in it, after mirage has started
    Given I run 'mirage start'
    When the file 'defaults/default_greetings.rb' contains:
    """
    A file with a mistake in it
    """
    And I hit 'http://localhost:7001/mirage/load_defaults'
    Then a 500 should be returned







