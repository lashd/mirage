Feature: URI wildcards

  Scenario: Setting a template with wildcards
    Given the following Template JSON:
    """
    {"response":{"body":"SGVsbG8="}}
    """
    And the template is sent using PUT to '/templates/greeting/*/davis'
    When GET is sent to '/responses/greeting/leon/davis'
    Then 'Hello' should be returned
