Feature: Mirage can also be used to host files.

  #TODO - generate zip file or move resources directory
  Scenario: A file is set as a response
    Given I hit 'http://localhost:7001/mirage/set/some/location/download' with parameters:
      | response | features/resources/test.zip |

    When I hit 'http://localhost:7001/mirage/get/some/location/download'
    Then the response should be a file the same as 'features/resources/test.zip'