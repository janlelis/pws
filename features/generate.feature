Feature: Generate
  In order to have safe passwords in my password safe
  As a user
  I want to generate passwords and add them to my password safe

  @wait-11s
  @slow-hack
  Scenario: Generate a new password for "github" and gets it
    Given A safe exists with master password "my_master_password"
    When I run `pws generate github` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "The password for github has been added"
    And  the output should contain "The password for github is now available in your clipboard for 10 seconds"
    
  @slow-hack
  Scenario: Generate a new password for "github", second parameter gets passed to the get as keep-in-clipboard time 
    Given A safe exists with master password "my_master_password"
    When I run `pws generate github 1` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "The password for github has been added"
    And  the output should contain "The password for github is now available in your clipboard for 1 second"

  @wait-11s
  @slow-hack
  Scenario: Generate a new password for "github", PWS_SECONDS set to 5, gets passed to the get as keep-in-clipboard time
    Given A safe exists with master password "my_master_password"
    When I set env variable "PWS_SECONDS" to "5"
    And I run `pws generate github` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "The password for github has been added"
    And  the output should contain "The password for github is now available in your clipboard for 5 seconds"

  @slow-hack
  Scenario: Generate a new password for "github", third parameter defines password length 
    Given A safe exists with master password "my_master_password"
    When I run `pws generate github 0 10` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "The password for github has been added"
    And  the output should contain "The password for github has been copied to your clipboard"
    And  the clipboard should match /^.{10}$/
    
  @slow-hack
  Scenario: Generate a new password for "github", default length is 64 
    Given A safe exists with master password "my_master_password"
    When I run `pws generate github 0` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "The password for github has been added"
    And  the output should contain "The password for github has been copied to your clipboard"
    And  the clipboard should match /^.{64}$/
    
  @slow-hack
  Scenario: Generate a new password for "github", fourth parameter defines a char pool used for generation 
    Given A safe exists with master password "my_master_password"
    When I run `pws generate github 0 10 a` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "The password for github has been added"
    And  the output should contain "The password for github has been copied to your clipboard"
    And  the clipboard should match /^a{10}$/
    
  @slow-hack
  Scenario: Generate a new password for "github", the default char pool is !\"\#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~ 
    Given A safe exists with master password "my_master_password"
    When I run `pws generate github 0` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "The password for github has been added"
    And  the output should contain "The password for github has been copied to your clipboard"
    And  the clipboard should match ^[!\"\#$%&'()*+,\-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ\[\\\]^_`abcdefghijklmnopqrstuvwxyz{|}~]+$
    
  
