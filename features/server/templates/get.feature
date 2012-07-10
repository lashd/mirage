Feature: If you want to see the content of a particular response without triggering then it can be peeked instead.
  To do this, the responses unique id is required to identify it
    

  #TODO should return headers as well
  Scenario: Peeking a text based response
    Given I send PUT to 'http://localhost:7001/mirage/templates/xml' with body '<xml></xml>' and headers:
      | content-type | text/xml |

    When I send GET to 'http://localhost:7001/mirage/templates/1'
    Then '<xml></xml>' should be returned
    And the response 'content-type' should be 'text/xml'


  Scenario: Peeking a file based response
    Given the file 'test_file.txt' contains:
    """
    test content
    """
    And I send PUT to 'http://localhost:7001/mirage/templates/some/location/download' with file: test_file.txt and headers:
      | X-mirage-file | true |

    When I send GET to 'http://localhost:7001/mirage/templates/1'
    Then the response should be the same as the content of 'test_file.txt'


  Scenario: Peeking a response that does not exist
    When I send GET to 'http://localhost:7001/mirage/templates/1'
    Then a 404 should be returned


