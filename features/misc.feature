Feature: Misc
  In order to be happy with my passwords safe
  As a user
  I want ensure the password safe behaves nicely

  Scenario: I am calling with too few arguments
  Given A safe exists with master password "my_master_password" and a key "github" with password "github_password"
    When I run `pws get` interactively
    And  I type "my_master_password"
    And  the output should contain "Wrong number of arguments"
    
  Scenario: I am calling with too many arguments
  Given A safe exists with master password "my_master_password" and a key "github" with password "github_password"
    When I run `pws get github with far too many args` interactively
    And  I type "my_master_password"
    And  the output should contain "Wrong number of arguments"
    
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
  
  Scenario: I am asking for the version
    When I run `pws --version` interactively
    And  the output should contain "pws"
    And  the output should contain "J-_-L"
    And  the output should contain "github"
  
  Scenario: I want to use a .pws file in the current directory
    When I run `pws --cwd ls` interactively
    And  I type "123"
    And  I type "456"
    Then the output should contain the current path
    And  the output should contain ".pws"
    And  the output should contain "The passwords don't match!"
