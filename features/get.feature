Feature: Get
  In order to have a helpful password safe
  As a user
  I want to get passwords from my password safe

  Scenario: Get the password for "github" (which exists) and copy it to the clipboard
    Given A safe exists with master password "my_master_password" and a key "github" with password "github_password"
    When I run `pws get github 0` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "The password for github has been copied to your clipboard"
    And  the clipboard should contain "github_password"

  @wait-11s
  Scenario: Get the password for "github" (which exists) and keep it in the clipboard for 10 seconds
    Given A safe exists with master password "my_master_password" and a key "github" with password "github_password"
    When I run `pws get github` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "The password for github is now available in your clipboard for 10 seconds"

  Scenario: Get the password for "github" (which exists) and keep it in the clipboard for 1 second
    Given A safe exists with master password "my_master_password" and a key "github" with password "github_password"
    When I run `pws get github 1` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "The password for github is now available in your clipboard for 1 second"

  @wait-11s
  Scenario: Get the password for "github" (which exists) and keep it in the clipboard for 5 seconds when PWS_SECONDS is set to 5
    Given A safe exists with master password "my_master_password" and a key "github" with password "github_password"
    When I set env variable "PWS_SECONDS" to "5"
    And  I run `pws get github` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "The password for github is now available in your clipboard for 5 seconds"

  Scenario: Get the password for "github" (which exists) and ensure that the original clipboard content gets restored
    Given A safe exists with master password "my_master_password" and a key "github" with password "github_password"
    Given A clipboard content of "blubb"
    When I run `pws get github 1` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "The password for github is now available in your clipboard for 1 second"
    And  the clipboard should contain "blubb"
    
  Scenario: Try to get the password for "google" (which does not exist)
    Given A safe exists with master password "my_master_password" and a key "github" with password "github_password"
    When I run `pws get google` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "No password found for google!"
    
  Scenario: Try to get the password for "github" (but the master password is wrong)
    Given A safe exists with master password "my_master_password" and a key "github" with password "github_password"
    When I run `pws get github` interactively
    And  I type "my_master_password_wrong"
    Then the output should contain "Master password:"
    And  the output should contain "NO ACCESS"

  Scenario: Get the password for "gihub" using an abbrev shortcut
    Given A safe exists with master password "my_master_password" and keys
      | github    | 123 |
      | google    | 345 |
      | gitorious | 678 |
    When I run `pws get gith 0` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "The password for github has been copied to your clipboard"
    And  the clipboard should contain "123"

    
  
