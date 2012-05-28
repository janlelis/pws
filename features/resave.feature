Feature: Resave
  In order to do nothing, but apply options to the safe and always save it
  As a user
  I want resave the save
  
  @slow-hack
  Scenario: Usual resave
    Given A safe exists with master password "my_master_password" and keys
      | some      | 123 |
      | password  | 345 |
      | entries   | 678 |
    When I run `pws resave` interactively
    And  I type "my_master_password"
    Then the output should contain "resaved"
    When I run `pws` interactively
    And  I type "my_master_password"
    And  the output should contain "some"
    And  the output should contain "password"
    And  the output should contain "entries"
    
  @slow-hack
  Scenario: Useful for converting when used together with --in and --out options
    Given A "0.9" safe exists with master password "password" and a key "github" with password "123456"
    When I run `pws show` interactively
    And  I type "password"
    Then the output should contain "Master password:"
    Then the output should contain "NO ACCESS"
    Then the output should contain "convert"
    When I run `pws resave --in 0.9 --out 1.0` interactively
    And  I type "password"
    Then the output should contain "Master password:"
    Then the output should contain "resaved"
    When I run `pws` interactively
    And  I type "password"
    Then the output should contain "Master password:"
    Then the output should contain "Entries"
    Then the output should contain "github"
