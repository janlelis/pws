Feature: Create
  In order to use the password safe
  As a user
  I want to create a new safe

  Scenario: Trying to call a pws task (except help or version), but safe does not exist, yet
    When I run `pws` interactively
    And I type "some_new_master_password"
    And I type "some_new_master_password"
    Then the output should match /No password safe detected, creating one at.*pws.*/
    And  the output should contain "Please enter the new master password:"
    And  the output should contain "Please enter the new master password, again:"
    And  the output should contain "There aren't any passwords stored"
    
  Scenario: Creating a new safe fails, if password confirmation is wrong 
    When I run `pws` interactively
    And I type "some_new_master_password"
    And I type "some_new_master_password_wrong"
    Then the output should match /No password safe detected, creating one at.*pws.*/
    And  the output should contain "Please enter the new master password:"
    And  the output should contain "Please enter the new master password, again:"
    And  the output should contain "don't match"
  
