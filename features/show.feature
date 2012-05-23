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
    
  Scenario: Show the list and filter for regex
    Given A safe exists with master password "my_master_password" and keys
      | some-abc       | 123 |
      | password-aDc!  | 345 |
      | entries        | 678 |
    When I run `pws show a.c` interactively
    And  I type "my_master_password"
    Then the output should contain "Entries"
    And  the output should contain "some-abc"
    And  the output should contain "password-aDc!"
    
  Scenario: Show the list and filter for regex, but regex is invalid
    Given A safe exists with master password "my_master_password" and keys
      | some-abc       | 123 |
      | password-aDc!  | 345 |
      | entries        | 678 |
    When I run `pws show "(("` interactively
    And  I type "my_master_password"
    Then the output should contain "Invalid regex"
    
  Scenario: Show the list and filter for regex, but no results
    Given A safe exists with master password "my_master_password" and keys
      | some-abc       | 123 |
      | password-aDc!  | 345 |
      | entries        | 678 |
    When I run `pws show unknown` interactively
    And  I type "my_master_password"
    Then the output should contain "No passwords found"
    
  Scenario: Also shows last change date for each entry
    Given A safe exists with master password "my_master_password" and a key "github" with password "github_password" and timestamp "42424242"
    When I run `pws show` interactively
    And  I type "my_master_password"
    Then the output should contain "Entries"
    And  the output should contain "github"
    And  the output should contain "71-05-07"
    
  Scenario: Don't show the last timestamp if it is 0
    Given A safe exists with master password "my_master_password" and a key "github" with password "github_password" and timestamp "0"
    When I run `pws show` interactively
    And  I type "my_master_password"
    Then the output should contain "Entries"
    And  the output should contain "github"
    And  the output should not contain "70-01-01"
    
  Scenario: Don't show the last timestamp if there is none
    Given A safe exists with master password "my_master_password" and a key "github" with password "github_password"
    When I run `pws show` interactively
    And  I type "my_master_password"
    Then the output should contain "Entries"
    And  the output should contain "github"
    And  the output should not contain "70-01-01"
    
  Scenario: Show the list (but there is no entry yet)
    Given A safe exists with master password "my_master_password"
    When I run `pws show` interactively
    And  I type "my_master_password"
    Then the output should contain "There aren't any passwords stored"
    
  Scenario: Show the list ("pws" without show is an alias)
    Given A safe exists with master password "my_master_password"
    When I run `pws` interactively
    And  I type "my_master_password"
    Then the output should contain "There aren't any passwords stored"
    
  Scenario: Try to show the list (but the master password is wrong)
    Given A safe exists with master password "my_master_password" and a key "github" with password "github_password"
    When I run `pws show` interactively
    And  I type "my_master_password_wrong"
    Then the output should contain "Master password:"
    And  the output should contain "NO ACCESS"
    
  
