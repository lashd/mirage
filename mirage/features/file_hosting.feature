Feature: Files can also be returned as a response

  Scenario: A file is put on the MockServer
    Given I hit 'http://localhost:7001/mirage/set/some/location/download' with parameters:
      | file | features/resources/test.zip |

    When I hit 'http://localhost:7001/mirage/get/some/location/download'
    Then the response should be a file the same as 'features/resources/test.zip'