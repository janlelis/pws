Feature: Show
  In order to have an overview of my password safe
  As a user
  I want show a list of password entry keys

  Scenario: Show the list
    Given A safe exists with master password "my_master_password" and keys
      | some      | 123 |
      | password  | 345 |
      | entries   | 678 |
    When I run `pws show` interactively
    And  I type "my_master_password"
    Then the output should contain "Entries"
    And  the output should contain "some"
    And  the output should contain "password"
    And  the output should contain "entries"

  Scenario: Show the list (but there is no entry yet)
    Given A safe exists with master password "my_master_password"
    When I run `pws show` interactively
    And  I type "my_master_password"
    Then the output should contain "No passwords stored"
    
  Scenario: Show the list ("pws" without show is an alias)
    Given A safe exists with master password "my_master_password"
    When I run `pws show` interactively
    And  I type "my_master_password"
    Then the output should contain "No passwords stored"
    
  Scenario: Try to show the list (but the master password is wrong)
    Given A safe exists with master password "my_master_password" and a key "github" with password "github_password"
    When I run `pws show` interactively
    And  I type "my_master_password_wrong"
    Then the output should contain "Master password:"
    And  the output should contain "Could not decrypt/load the password safe!"
