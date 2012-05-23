Feature: Namespaces and creating new safes
  In order to keep things separate
  As a user
  I want to use different safes

  Scenario: Use a pws namespace, creating a new safe
    When I run `pws -work show` interactively
    And I type "some_new_master_password"
    And I type "some_new_master_password"
    Then the output should match /No password safe detected, creating one at.*pws.*-work/
    And  the output should contain "Please enter the new master password:"
    And  the output should contain "Please enter the new master password, again:"
    And  the output should contain "There aren't any passwords stored"
    
  Scenario: Creating a new safe fails, if password confirmation is wrong 
    When I run `pws show` interactively
    And I type "some_new_master_password"
    And I type "some_new_master_password_wrong"
    Then the output should match /No password safe detected, creating one at.*pws.*/
    And  the output should contain "Please enter the new master password:"
    And  the output should contain "Please enter the new master password, again:"
    And  the output should contain "don't match"
    
  Scenario: Only passing "-" operates on usual main namespace 
    Given A safe exists with master password "my_master_password" and a key "github" with password "github_password"
    When I run `pws - show` interactively
    And I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "Entries"
    And  the output should contain "github"
    
  
