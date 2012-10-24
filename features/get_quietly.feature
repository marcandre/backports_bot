Feature: Silence Extraneous Output on Get
  In order to use StickyFlag in scripts
  As a power user
  I want to be able to get tags without extra output
  
  Scenario: Get tags without worrying about missing tags or files
    Given the example configuration
    When I quietly get the tags for "mmd_crazy_tags.mmd", "mmd_no_tags.mmd", and "nonexistent.mmd"
    Then the output should contain "mmd_crazy_tags.mmd: asdf, sdfg, dfgh, fghj, qwer"
      And the output should not contain "mmd_no_tags.mmd"
      And the output should not contain "nonexistent.mmd"
  
  Scenario: Determine quiet tag get success from return value
    Given the example configuration
    Given PENDING: figure out how to get Thor to do exit codes
    When I quietly get the tags for "mmd_crazy_tags.mmd"
    Then the exit status should be 0
  
  Scenario: Determine quiet tag get failure from return value
    Given the example configuration
    Given PENDING: figure out how to get Thor to do exit codes
    When I quietly get the tags for "nonexistent.mmd"
    Then the exit status should not be 0