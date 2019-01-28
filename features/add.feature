Feature: Add
  In order to have passwords in my password safe
  As a user
  I want to add new passwords to my password safe

  
  Scenario: Add a new password for "github"
    Given A safe exists with master password "my_master_password"
    When I run `pws add github` interactively
    And  I type "my_master_password"
    And  I type "github_password"
    Then the output should contain "Master password:"
    And  the output should contain "Please enter a password for github:"
    And  the output should contain "The password for github has been added"

  
  Scenario: Add a new password for "github", already passing it as command line paramenter (not recommended)
    Given A safe exists with master password "my_master_password"
    When I run `pws add github github_password` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "The password for github has been added"

  Scenario: Try to add a new password for "github" (but it already exists)
    Given A safe exists with master password "my_master_password" and a key "github" with password "github_password"
    When I run `pws add github` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "There is already a password stored for github. You need to remove it before creating a new one!"

  Scenario: Try to add a new password for "github" (but it's empty)
    Given A safe exists with master password "my_master_password"
    When I run `pws add github` interactively
    And  I type "my_master_password"
    And  I type ""
    Then the output should contain "Master password:"
    And  the output should contain "Please enter a password for github:"
    And  the output should contain "Cannot set an empty password!"

  Scenario: Try to add a new password for "github" (but the master password is wrong)
    Given A safe exists with master password "my_master_password"
    When I run `pws add github` interactively
    And  I type "my_master_password_wrong"
    Then the output should contain "Master password:"
    And  the output should contain "NO ACCESS"

  
  Scenario: Set a new password for "github", this also sets the timestamp
    Given A safe exists with master password "my_master_password" and a key "some" with password "entry"
    When I run `pws add github github_password` interactively
    And  I type "my_master_password"
    And  I run `pws show` interactively
    And  I type "my_master_password"
    Then the output should contain the current date
