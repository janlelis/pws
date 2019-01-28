Feature: PrintScreen
  In order to have a helpful password safe when I have no clipboard
  As a user
  I want to disply passwords from my password safe

  Scenario: Get the password for "github" (which exists) and print it to the screen
    Given A safe exists with master password "my_master_password" and a key "github" with password "github_password"
    When I run `pws ps github 0` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "The password for github is:\ngithub_password"

  
  Scenario: Get the password for "github" (which exists) and print it to the screen for 10 seconds
    Given A safe exists with master password "my_master_password" and a key "github" with password "github_password"
    When I run `pws ps github` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "The password for github will be displayed for 10 seconds:\ngithub"

  Scenario: Get the password for "github" (which exists) and print it to the screen for 1 second
    Given A safe exists with master password "my_master_password" and a key "github" with password "github_password"
    When I run `pws ps github 1` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "The password for github will be displayed for 1 second:\ngithub"

  
  Scenario: Get the password for "github" (which exists) and print it to the screen for 5 seconds when PWS_SECONDS is set to 5
    Given A safe exists with master password "my_master_password" and a key "github" with password "github_password"
    When I set env variable "PWS_SECONDS" to "5"
    And  I run `pws ps github` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "The password for github will be displayed for 5 seconds:\ngithub"

  Scenario: Try to get the password for "google" (which does not exist)
    Given A safe exists with master password "my_master_password" and a key "github" with password "github_password"
    When I run `pws ps google` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "No password found for google!"
    
  Scenario: Try to get the password for "github" (but the master password is wrong)
    Given A safe exists with master password "my_master_password" and a key "github" with password "github_password"
    When I run `pws ps github` interactively
    And  I type "my_master_password_wrong"
    Then the output should contain "Master password:"
    And  the output should contain "NO ACCESS"

  Scenario: Get the password for "gihub" using an abbrev shortcut
    Given A safe exists with master password "my_master_password" and keys
      | github    | 123 |
      | google    | 345 |
      | gitorious | 678 |
    When I run `pws ps gith 0` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "The password for github is:\n123"

    
  