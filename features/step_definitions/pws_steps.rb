require 'fileutils'

def create_safe(master, key_hash = {}, timestamp = nil)
  ENV["PWS_CHARPOOL"] = ENV["PWS_LENGTH"] = ENV["PWS_SECONDS"] = nil
  restore, $stdout = $stdout, StringIO.new # tmp silence $stdout
  pws = PWS.new(password: master, iterations: 5)
  key_hash.each{ |key, password|
    pws.add key, password
  }
  
  # only generating global timestamp for every entry
  if timestamp
    pws.instance_variable_get(:@data).each{ |_, entry|
      entry[:timestamp] = timestamp
    }
    pws.resave
  end
  
  $stdout = restore
end

# faking legacy version safe using a fixture, maybe do it properly sometime
def create_09_safe
  FileUtils.cp File.dirname(__FILE__) + '/../../spec/fixtures/0.9/correct', ENV['PWS']
end

Given /^A safe exists with master password "([^"]*)"$/ do |master_password|
  create_safe(master_password)
end

Given /^A safe exists with master password "([^"]*)" and a key "([^"]+)" with password "([^"]+)"$/ do |master_password, key, password|
  create_safe(master_password, key => password)
end

Given /^A safe exists with master password "([^"]*)" and a key "([^"]+)" with password "([^"]+)" and timestamp "([^"]+)"$/ do |master_password, key, password, timestamp|
  create_safe(master_password, { key => password }, timestamp)
end

Given /^A safe exists with master password "([^"]*)" and keys$/ do |master_password, key_table|
  create_safe(master_password, key_table.rows_hash)
end

Given /^A "0.9" safe exists with master password "password" and a key "github" with password "123456"$/ do
  create_09_safe
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

Then /^the output should contain the current date$/ do
  assert_partial_output(Time.now.strftime('%y-%m-%d'), all_output)
end

Then /^the output should not contain the current date$/ do
  assert_no_partial_output(Time.now.strftime('%y-%m-%d'), all_output)
end

Then /^the output from "([^"]*)" should contain the current date$/ do |cmd|
  assert_partial_output(Time.now.strftime('%y-%m-%d'), output_from(cmd))
end

Then /^the output from "([^"]*)" should not contain the current date$/ do |cmd|
  assert_no_partial_output(Time.now.strftime('%y-%m-%d'), output_from(cmd))
end

Then /^the output should contain the current path$/ do
  assert_partial_output(FileUtils.pwd, all_output)
end

When /^I set env variable "(\w+)" to "([^"]*)"$/ do |var, value|
  ENV[var] = value
end
