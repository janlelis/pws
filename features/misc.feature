Feature: Misc
  In order to be happy with my passwords safe
  As a user
  I want ensure the password safe behaves nicely

  @slow-hack
  Scenario: I am calling with a wrong argument count
    Given A safe exists with master password "my_master_password" and a key "github" with password "github_password"
    When I run `pws get` interactively
    And  I type "my_master_password"
    And  the output should contain "Wrong number of arguments"
    When I run `pws get github with far too many args` interactively
    And  I type "my_master_password"
    And  the output from "pws get github with far too many args" should contain "Wrong number of arguments"
    
  Scenario: I am calling a task that does not exist
  Given A safe exists with master password "my_master_password" and a key "github" with password "github_password"
    When I run `pws blubb` interactively
    And  the output should contain "Unknown action"
    And  the output should contain "blubb"
    
  Scenario: I am asking for help
    When I run `pws --help` interactively
    And  the output should contain "Usage"
    And  the output should contain "pws"
    And  the output should contain "action"
    And  the output should contain "help"
    And  the output should contain "namespace"
    And  the output should contain "master"
  
