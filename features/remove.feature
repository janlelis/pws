Feature: Remove
  In order to keep my password safe clean
  As a user
  I want to remove passwords from my password safe
  
  Scenario: Remove password entry "github"
    Given A safe exists with master password "my_master_password" and a key "github" with password "github_password"
    When I run `pws remove github` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "Password for github has been removed."
  
  Scenario: Try to remove password entry for "google" (which does not exist)
    Given A safe exists with master password "my_master_password" and a key "github" with password "github_password"
    When I run `pws remove google` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "Nothing removed!"
    
  Scenario: Try to remove password entry "github" (but the master password is wrong)
    Given A safe exists with master password "my_master_password"
    When I run `pws remove github` interactively
    And  I type "my_master_password_wrong"
    Then the output should contain "Master password:"
    And  the output should contain "NO ACCESS"
    
  
