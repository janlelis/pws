Feature: Update
  In order to keep my privacy
  As a user
  I want to update a password entry and generate the new password

  
  Scenario: Generate a new password for "github" and get it
    Given A safe exists with master password "my_master_password" and a key "github" with password "old_password"
    When I run `pws update-gen github` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "The password for github has been updated"
    And  the output should contain "The password for github is now available in your clipboard for 10 seconds"
  
  Scenario: Try to update-gen the password for "github" (but it does not exist)
    Given A safe exists with master password "my_master_password"
    When I run `pws update-gen github` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "There is no password stored for github, so you cannot update it!"
    
  Scenario: Try to update-gen the password for "github" (but the master password is wrong)
    Given A safe exists with master password "my_master_password" and a key "github" with password "old_password"
    When I run `pws update-gen github` interactively
    And  I type "my_master_password_wrong"
    Then the output should contain "Master password:"
    And  the output should contain "NO ACCESS"
    
  
  Scenario: Generate a new password for "github" and get it
    Given A safe exists with master password "my_master_password" and a key "github" with password "old_password"
    When I run `pws update-gen github` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "The password for github has been updated"
    And  the output should contain "The password for github is now available in your clipboard for 10 seconds"
    
  
  Scenario: Generate a new password for "github", second parameter gets passed to the get as keep-in-clipboard time 
    Given A safe exists with master password "my_master_password" and a key "github" with password "old_password"
    When I run `pws update-gen github 1` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "The password for github has been updated"
    And  the output should contain "The password for github is now available in your clipboard for 1 second"

  
  
  Scenario: Generate a new password for "github", PWS_SECONDS set to 5, gets passed to the get as keep-in-clipboard time
    Given A safe exists with master password "my_master_password" and a key "github" with password "old_password"
    When I set env variable "PWS_SECONDS" to "5"
    And I run `pws update-gen github` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "The password for github has been updated"
    And  the output should contain "The password for github is now available in your clipboard for 5 seconds"

  
  Scenario: Generate a new password for "github", third parameter defines password length 
    Given A safe exists with master password "my_master_password" and a key "github" with password "old_password"
    When I run `pws update-gen github 0 10` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "The password for github has been updated"
    And  the output should contain "The password for github has been copied to your clipboard"
    And  the clipboard should match /^.{10}$/
    
  
  Scenario: Generate a new password for "github", default length is 64 
    Given A safe exists with master password "my_master_password" and a key "github" with password "old_password"
    When I run `pws update-gen github 0` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "The password for github has been updated"
    And  the output should contain "The password for github has been copied to your clipboard"
    And  the clipboard should match /^.{64}$/
    
  
  Scenario: Generate a new password for "github", default length of PWS_LENGTH
    Given A safe exists with master password "my_master_password" and a key "github" with password "old_password"
    When I set env variable "PWS_LENGTH" to "15"
    And  I run `pws update-gen github 0` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "The password for github has been updated"
    And  the output should contain "The password for github has been copied to your clipboard"
    And  the clipboard should match /^.{15}$/

  
  Scenario: Generate a new password for "github", fourth parameter defines a char pool used for generation 
    Given A safe exists with master password "my_master_password" and a key "github" with password "old_password"
    When I run `pws update-gen github 0 10 a` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "The password for github has been updated"
    And  the output should contain "The password for github has been copied to your clipboard"
    And  the clipboard should match /^a{10}$/
    
  
  Scenario: Generate a new password for "github", the default char pool is !\"\#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~ 
    Given A safe exists with master password "my_master_password" and a key "github" with password "old_password"
    When I run `pws update-gen github 0` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "The password for github has been updated"
    And  the output should contain "The password for github has been copied to your clipboard"
    And  the clipboard should match ^[!\"\#$%&'()*+,\-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ\[\\\]^_`abcdefghijklmnopqrstuvwxyz{|}~]+$
    
  
  Scenario: Generate a new password for "github", the default char pool PWS_CHARPOOL
    Given A safe exists with master password "my_master_password" and a key "github" with password "old_password"
    When I set env variable "PWS_CHARPOOL" to "a"
    When I run `pws update-gen github 0` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "The password for github has been updated"
    And  the output should contain "The password for github has been copied to your clipboard"
    And  the clipboard should match ^a{64}$

  Scenario: Generate a new password for "github", exclude the characters "ABC123" from the charpool
    Given A safe exists with master password "my_master_password" and a key "github" with password "old_password"
    When I run `pws update-gen github 0 --exclude ABC123` interactively
    And  I type "my_master_password"
    Then the output should contain "Master password:"
    And  the output should contain "The password for github has been updated"
    And  the output should contain "The password for github has been copied to your clipboard"
    And  the clipboard should match [^ABC123]{64}
