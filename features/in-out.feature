Feature: --in and --out options
  In order to use the newest pws version
  As a user
  I want to convert my password file into a different file format
  
  Scenario: Cannot access a 0.9 safe with the current version without --in 0.9 option
  Given A "0.9" safe exists with master password "password" and a key "github" with password "123456"
    When I run `pws` interactively
    And  I type "password"
    And  the output should contain "NO ACCESS"
    And  the output should contain "you will need to convert"
  
  Scenario: Can access a 0.9 safe, if --in 0.9 option is given
    Given A "0.9" safe exists with master password "password" and a key "github" with password "123456"
    When I run `pws --in 0.9` interactively
    And  I type "password"
    Then the output should contain "Master password:"
    Then the output should contain "Entries"
    Then the output should contain "github"
  
  Scenario: Using --in 0.5 option, but --in 0.5 is not supported
    Given A safe exists with master password "password" and a key "github" with password "123456"
    When I run `pws --in 0.5` interactively
    And  I type "password"
    Then the output should contain "Master password:"
    Then the output should contain "Input format <0.5> is not supported"
  
  Scenario: Using --in 0.9 option, but safe is not in 0.9 format
    Given A safe exists with master password "password" and a key "github" with password "123456"
    When I run `pws --in 0.9` interactively
    And  I type "password"
    Then the output should contain "Master password:"
    Then the output should contain "NO ACCESS"
  
  @slow-hack
  Scenario: Succesfully converts from 0.9 to 1.0 with --in 0.9 and out --1.0 options
    Given A "0.9" safe exists with master password "password" and a key "github" with password "123456"
    When I run `pws resave --in 0.9 --out 1.0` interactively
    And  I type "password"
    Then the output from "pws resave --in 0.9 --out 1.0" should contain "Master password:"
    Then the output from "pws resave --in 0.9 --out 1.0" should contain "resaved"
    When I run `pws` interactively
    And  I type "password"
    Then the output from "pws" should contain "Master password:"
    Then the output from "pws" should contain "Entries"
    Then the output from "pws" should contain "github"
  
  Scenario: Trying to convert to 0.9, but --out 0.9 is not supported
    Given A "0.9" safe exists with master password "password" and a key "github" with password "123456"
    When I run `pws resave --in 0.9 --out 0.9` interactively
    And  I type "password"
    Then the output should contain "Master password:"
    Then the output should contain "Output format <0.9> is not supported"
  
