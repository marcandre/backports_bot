Feature: Silence Extraneous Output
  In order to use StickyFlag in scripts
  As a power user
  I want to be able to silence extraneous command output
  
  Scenario: Get tags without worrying about missing tags or files
    Given the example configuration
    When I quietly get the tags for "mmd_crazy_tags.mmd", "mmd_no_tags.mmd", and "nonexistent.mmd"
    Then the output should contain "mmd_crazy_tags.mmd: asdf, sdfg, dfgh, fghj, qwer"
      And the output should not contain "mmd_no_tags.mmd"
      And the output should not contain "nonexistent.mmd"

  Scenario: Set tags with no output at all
    Given the example configuration
    When I quietly set the tag "test2" for "mmd_crazy_tags.mmd"
    Then the output should not contain "mmd_crazy_tags.mmd"
      And the output should not contain "test2"
  
  Scenario: Determine tag success from return value
    Given the example configuration
    Given PENDING: figure out how to get Thor to do exit codes
    When I quietly set the tag "test2" for "mmd_crazy_tags.mmd"
    Then the exit status should be 0
  
  Scenario: Determine tag failure from return value
    Given the example configuration
    Given PENDING: figure out how to get Thor to do exit codes
    When I quietly set the tag "test2" for "nonexistent.mmd"
    Then the exit status should not be 0
