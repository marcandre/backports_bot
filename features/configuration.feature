Feature: Persistent Configuration
  In order to customize the behavior of StickyFlag
  As a new user
  I want to be able to set persistent configuration values
  
  Scenario: Set and query a configuration value
    Given a clean configuration
    When I set the configuration key "root" to "/test/"
      And I get the configuration key "root"
    Then the output should contain "root: '/test/'"
  
  Scenario: Query a previously set configuration value
    When I get the configuration key "root"
    Then the output should contain "root: '/test/'"
