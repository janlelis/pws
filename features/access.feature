Feature: Access
  In order to use the password safe
  As a user
  I want to create a new safe

  Scenario: Trying to call a pws task (except help or version), but safe does not exist, yet
    When I run `pws` interactively
    And I type "some_new_master_password"
    Then the output should contain "No password safe detected, creating one at"
    And  the output should contain "Please enter a new master password:"
    And  the output should contain "No passwords stored"
