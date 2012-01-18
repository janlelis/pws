require_relative 'pws/version'
require_relative 'pws/encryptor'

require 'fileutils'
require 'clipboard'
require 'securerandom'
require 'zucker/alias_for'
require 'paint/pa'

class PWS
  class NoAccess < StandardError; end
   
  # Creates a new password safe. Takes the path to the password file, by default: ~/.pws 
  # You can pass the master password as second parameter (not recommended)
  def initialize(filename = nil, password = nil)
    @pw_file = File.expand_path(filename || ENV["PWS"] || '~/.pws')
    access_safe(password)
    read_safe
  end

  # Add a password entry, params: name, password (optional, opens prompt if not given)
  def add(key, password = nil)
    if @pw_data[key]
      pa %[There is already a password stored for #{key}. You need to remove it before creating a new one!], :red
      return false
    else
      @pw_data[key] = password || ask_for_password(%[please enter a new password for #{key}], :yellow)
      if @pw_data[key].empty?
        pa %[Cannot add an empty password!], :red
        return false
      else
        write_safe
        pa %[The password for #{key} has been added.], :green
        return true
      end
    end
  end
  aliases_for :add, :a, :set, :store, :create, :[]= # using zucker/alias_for

  # Gets the password entry and copies it to the clipboard. The second parameter is the time in seconds it stays there
  def get(key, seconds = 5)
    if pw_plaintext = @pw_data[key]
      if seconds && seconds.to_i > 0
        original_clipboard_content = Clipboard.paste
        Clipboard.copy pw_plaintext
        pa %[The password for #{key} is now available in your clipboard for #{seconds.to_i} second#{?s if seconds.to_i > 1}.], :green
        begin
          sleep seconds.to_i
        rescue Interrupt
          Clipboard.copy original_clipboard_content
          raise
        end
        Clipboard.copy original_clipboard_content
        return true
      else
        Clipboard.copy pw_plaintext
        pa %[The password for #{key} has been copied to your clipboard.], :green
        return true
      end
    else
      pa %[No password found for #{key}!], :red
      return false
    end
  end
  aliases_for :get, :g, :entry, :[]

  # Adds a password entry with a freshly generated random password
  def generate(
        key,
        seconds = 5,
        length = 64,
        char_pool = (32..126).map(&:chr).join.gsub(/\s/, '')
    )
    char_pool_size = char_pool.size
    new_pw = (1..length.to_i).map{
      char_pool[SecureRandom.random_number(char_pool_size)]
    }.join
    
    if add(key, new_pw) 
      get(key, seconds)
    end
  end
  alias_for :generate, :gen

  # Removes a specific password entry
  def remove(key)
    if @pw_data.delete key
      write_safe
      pa %[Password for #{key} has been removed.], :green
      return true
    else
      pa %[Nothing removed!], :red
      return false
    end
  end
  aliases_for :remove, :r, :delete

  # Shows a password entry list
  def show
    if @pw_data.empty? 
      puts %[No passwords stored in #{@pw_file} yet.]
    else
      puts Paint["Entries", :underline] + %[ in ] + @pw_file
      puts @pw_data.keys.map{ |key| %[- #{key}\n] }.join
    end
    return true
  end
  aliases_for :show, :s, :list

  # Changes the master password
  def master(password = nil)
    @pw_hash = Encryptor.hash password || ask_for_password(%[please enter a new master password], :yellow, :bold)
    write_safe
    pa %[The master password has been changed.], :green
    return true
  end
  aliases_for :master, :m

  # Prevents accidental displaying, e.g. in irb
  def to_s
    %[#<password safe>]
  end
  alias_for :to_s, :inspect

  private

  # Tries to load and decrypt the password safe from the pwfile
  def read_safe
    pwdata_raw       = File.read(@pw_file)
    pwdata_encrypted = pwdata_raw.force_encoding("ascii")
    pwdata_dump      = Encryptor.decrypt(pwdata_encrypted, @pw_hash)
    pwdata_with_redundancy = Marshal.load(pwdata_dump)
    @pw_data          = remove_redundancy(pwdata_with_redundancy)
  rescue
    fail NoAccess, %[Could not decrypt/load the password safe!]
  end

  # Tries to encrypt and save the password safe into the pwfile
  def write_safe
    pwdata_with_redundancy = add_redundancy(@pw_data || {})
    pwdata_dump      = Marshal.dump(pwdata_with_redundancy)
    pwdata_encrypted = Encryptor.encrypt(pwdata_dump, @pw_hash)
    File.open(@pw_file, 'w'){ |f| f.write(pwdata_encrypted) }
  rescue
    fail NoAccess, %[Could not encrypt/safe the password safe!]
  end
  
  # Checks if the file is accessible or create a new one
  def access_safe(password = nil)
    if !File.file? @pw_file
      pa %[No password safe detected, creating one at #@pw_file], :blue, :bold
      @pw_hash = Encryptor.hash password || ask_for_password(%[please enter a new master password], :yellow, :bold)
      write_safe
    else
      print %[Access password safe at #@pw_file | ]
      @pw_hash = Encryptor.hash password || ask_for_password(%[master password])
    end
  rescue
    fail NoAccess, %[Could not access the password safe at #@pw_file]
  end

  # Adds some redundancy (to conceal how much you have stored)
  def add_redundancy(pwdata)
    entries  = 8000 + SecureRandom.random_number(4000)
    position = SecureRandom.random_number(entries)
    
    ret = entries.times.map{ SecureRandom.uuid.chars.to_a.shuffle.join } # or whatever
    ret[position] = pwdata
    ret << position

    ret
  end

  # And remove it
  def remove_redundancy(pwdata)
    position = pwdata[-1]
    pwdata[position]
  end

  # Prompts the user for a password
  def ask_for_password(prompt = 'new password', *colors)
    print Paint["#{prompt}:".capitalize, *colors] + " "
    system 'stty -echo' if $stdin.tty?     # no more terminal output
    pw_plaintext = ($stdin.gets||'').chop  # gets without $stdin would mistakenly read_safe from ARGV
    system 'stty echo'  if $stdin.tty?     # restore terminal output
    puts "\e[999D\e[K\e[1A"                # re-use prompt line in terminal

    pw_plaintext
  end
end

# See bin/pws for command line action

# J-_-L
