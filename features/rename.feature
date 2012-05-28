Feature: Rename
  In order to reorder my password safe
  As a user
  I want to rename passwords in my password safe

  @very-slow-hack
  Scenario: Rename the password entry "github" to "gh"
    Given A safe exists with master password "my_master_password" and a key "github" with password "github_password"
    When I run `pws rename github gh` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "The password entry github has been renamed to gh"
    When I run `pws show` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "Entries"
    And  the output should contain "gh"
    And  the output from "pws show" should not contain "github"

  Scenario: Try to rename the password entry "github" to "gh" (but github does not exist)
    Given A safe exists with master password "my_master_password"
    When I run `pws rename github gh` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "No password found for github!"
    
  Scenario: Try to rename the password entry "github" to "gh" (but gh already exists)
    Given A safe exists with master password "my_master_password" and keys
      | github | github_password |
      | gh     | gh_password     |
    When I run `pws rename github gh` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "There is already a password stored for gh. You need to remove it before naming another one gh!"
    
    Scenario: Try to rename the password entry "github" to "gh" (but the master password is wrong)
    Given A safe exists with master password "my_master_password"
    When I run `pws rename github gh` interactively
    And  I type "my_master_password_wrong"
    Then the output should contain "Master password:"
    And  the output should contain "NO ACCESS"
    
  
