Feature: Master
  In order to keep my passwords safe
  As a user
  I want to change the master password

  @slow-hack
  Scenario: Change the master password and check that it has changed
    Given A safe exists with master password "my_master_password"
    When I run `pws master` interactively
    And  I type "my_master_password"
    And  I type "my_new_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "Please enter a new master password:"
    And  the output should contain "The master password has been changed."
    When I run `pws` interactively
    And  I type "my_master_password"
    And  the output should contain "Master password:"
    And  the output should contain "Could not decrypt/load the password safe!"
    
  Scenario: Change the master password, already passing it as command line paramenter (not recommended)
    Given A safe exists with master password "my_master_password"
    When I run `pws master my_new_master_password` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "The master password has been changed."
    
  @slow-hack
  Scenario: I can have an empty master password (not recommended)
    Given A safe exists with master password "my_master_password"
    When I run `pws master` interactively
    And  I type "my_master_password"
    And  I type ""
    Then the output should contain "Master password:"
    And  the output should contain "The master password has been changed."
    When I run `pws` interactively
    And  I type ""
    Then the output should contain "Master password:"
    And  the output should contain "No passwords stored"
    
  Scenario: Try to change the master password (but enter the old one wrong)
    Given A safe exists with master password "my_master_password"
    When I run `pws master` interactively
    And  I type "my_master_password_wrong"
    Then the output should contain "Master password:"
    And  the output should contain "Could not decrypt/load the password safe!"
