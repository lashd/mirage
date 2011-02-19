Feature: Files can also be returned as a response

  Scenario: A file is put on the MockServer
    Given the response for 'some/location/download' is file 'features/resources/test.zip'
    When getting 'some/location/download'
    Then the response should be a file the same as 'features/resources/test.zip'