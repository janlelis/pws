def create_safe(master, key_hash = {})
  restore, $stdout = $stdout, StringIO.new # tmp silence $stdout
  pws = PWS.new ENV["PWS"], master
  key_hash.each{ |key, password|
    pws.add key, password
  }
  $stdout = restore
end

Given /^A safe exists with master password "([^"]*)"$/ do |master_password|
  create_safe(master_password)
end

Given /^A safe exists with master password "([^"]*)" and a key "([^"]+)" with password "([^"]+)"$/ do |master_password, key, password|
  create_safe(master_password, key => password)
end

Given /^A safe exists with master password "([^"]*)" and keys$/ do |master_password, key_table|
  create_safe(master_password, key_table.rows_hash)
end

Given /^A clipboard content of "([^"]*)"$/ do |content|
  Clipboard.copy content
end

Then /^the clipboard should contain "([^"]*)"$/ do |password|
  password.should == Clipboard.paste
end

Then /^the clipboard should match \/([^\/]*)\/$/ do |expected|
  assert_matching_output(expected, Clipboard.paste) 
end

Then /^the clipboard should match ([^\/].+)$/ do |expected|
  assert_matching_output(expected, Clipboard.paste) 
end
