Feature: Get List of Tags in Use
  In order to know which tags I've already used
  As a user with some tagged files
  I want to be able to get a list of all file tags
  
  Scenario: Get list of tags
    Given the example database
    When I get the list of tags in use
    Then the output should contain "   test"
      And the output should contain "   asdf"
      And the output should contain "Tags currently in use:"
      And the output should not contain "rspec"
    
  Scenario: Get bare list of tags for scripting
    Given the example database
    When I quietly get the list of tags in use
    Then the output should not contain "Tags currently in use:"
      And the output should contain "\ntest\n"
