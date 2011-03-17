@command_line
Feature: Mirage can be primed with a default responses.
  By default, Mirage loads any rb files found in ./defaults on startup. Mirage can also be made to load default responses
  from a directory of your choosing.

  Defaults can also be added/reloaded after Mirage has started


  Scenario: Mirage is started with defaults in the standard location.
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


  Scenario: Mirage is started pointing with a relative path for default responses
    Given the file './custom_default_location/default_greetings.rb' contains:
    """
    Mirage.default do |mirage|
      mirage.set('greeting', :response => 'hello')
    end
    """
    And I run 'mirage start -d ./custom_default_location'
    When I hit 'http://localhost:7001/mirage/get/greeting'
    Then 'hello' should be returned


  Scenario: Mirage is started pointing with a full path for default responses
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


  Scenario: Reloading default responses after mirage has been started
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


  Scenario: Mirage is started with a bad defaults file
    Given the file 'defaults/default_greetings.rb' contains:
    """
    A file with a mistake in it
    """
    When I run 'mirage start'
    Then I should see 'WARN: Unable to load default responses from: defaults/default_greetings.rb' on the command line


  Scenario: Defaults with a mistake in them are reloaded after mirage has been started
    Given I run 'mirage start'
    When the file 'defaults/default_greetings.rb' contains:
    """
    A file with a mistake in it
    """
    And I hit 'http://localhost:7001/mirage/load_defaults'
    Then a 500 should be returned







