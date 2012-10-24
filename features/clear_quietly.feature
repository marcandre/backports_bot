Feature: Silence Extraneous Output on Clear
  In order to use StickyFlag in scripts
  As a power user
  I want to be able to clear tags without any output at all
  
  Scenario: Clear tags without worrying about missing tags or files
    Given the example configuration
    When I quietly clear the tags for "mmd_crazy_tags.mmd", "mmd_no_tags.mmd", and "nonexistent.mmd"
    Then the output should not contain "mmd_crazy_tags.mmd"
      And the output should not contain "mmd_no_tags.mmd"
      And the output should not contain "nonexistent.mmd"
  
  Scenario: Determine quiet tag clear success from return value
    Given the example configuration
    Given PENDING: figure out how to get Thor to do exit codes
    When I quietly clear the tags for "mmd_crazy_tags.mmd"
    Then the exit status should be 0
  
  Scenario: Determine quiet tag clear failure from return value
    Given the example configuration
    Given PENDING: figure out how to get Thor to do exit codes
    When I quietly clear the tags for "nonexistent.mmd"
    Then the exit status should not be 0
