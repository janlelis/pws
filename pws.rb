#!/usr/bin/env ruby

# pws
#  see http://rbjl.net/41-tutorial-build-your-own-password-safe-with-ruby for more information

require 'rubygems' if RUBY_VERSION[2] == ?8

require 'openssl'
require 'fileutils'
require 'clipboard'        # gem install clipboard
require 'zucker/alias_for' # gem install zucker
require 'zucker/kernel'
require 'zucker/version'

class PasswordSafe
  VERSION = "0.1.3".freeze

  Entry = Struct.new :description, :password

  class NoAccess < StandardError; end
   
  # Creates a new password safe. Takes the path to the password file, by default: ~/.pws 
  def initialize( filename = File.expand_path('~/.pws') )
    @pwfile = filename

    access_safe
    read_safe
  end

  # Add a password entry, params: name, description (optional), password (optional, opens prompt if not given)
  def add(key, description = nil, password = nil)
    if @pwdata[key]
      print "Do you really want to overwrite the exisiting password entry? (press <Enter> to proceed)"
      return unless (a = $stdin.getc) == 10 || a == 13
    else
      @pwdata[key] = Entry.new
    end
    @pwdata[key].password    = password || ask_for_password( "please enter a password for #{key}" )
    @pwdata[key].description = description
    write_safe

    puts "The password safe has been updated"
  end
  aliases_for :add, :a, :set, :create, :update, :[]= # using zucker/alias_for

  # Gets the password entry and copies it to the clipboard. The second parameter is the time in seconds it stays there
  def get(key, seconds = 20)
    if pw_plaintext = @pwdata[key] && @pwdata[key].password
      Clipboard.copy pw_plaintext
      if seconds && seconds.to_i > 0
        puts "The password is available in your clipboard for #{seconds.to_i} seconds"
        sleep seconds.to_i
        Clipboard.clear
      else
        puts "The password has been copied to your clipboard"
      end
    else
      puts "No password entry found for #{key}"
    end
  end
  aliases_for :get, :g, :entry, :[]

  # Removes a specific password entry
  def remove(key)
    if @pwdata.delete key
      puts "#{key} has been removed"
    else
      puts "Nothing removed"
    end
  end
  aliases_for :remove, :r, :delete

  # Shows a password entry list
  def show
    puts "Available passwords \n" +

    if @pwdata.empty? 
      '  (none)'
    else
      @pwdata.map{ |key, pwentry|
        "  #{key}" + if pwentry.description then ": #{pwentry.description}" else '' end
      }*"\n" 
    end
  end
  aliases_for :show, :s, :list

  # Shows descriptions of some password entries
  def description(*keys)
    keys.each{ |key|
      if @pwdata[key]
        puts "#{key}: #{@pwdata[key].description || key}"
      else
        puts "No password entry found for #{key}"
      end
    }
  end

  # Changes the master password
  def master
    @pwhash = Encryptor.hash ask_for_password 'please enter a new master password'
    write_safe
    puts 'The master password has been changed'
  end
  aliases_for :master, :m

  # Adds a password entry with a fresh generated random password
  def generate( key, description = nil, length = 128, chars = (32..126).map(&:chr) )
    add key, nil, (1..length).map{ chars[rand chars.size] }.join # possible in 1.9: chars.sample
  end
  alias_for :generate, :gen

  # Prevents accidental displaying, e.g. in irb
  def to_s
    '#<just another password safe>'
  end
  alias_for :to_s, :inspect

  private

  # Tries to load and decrypt the password safe from the pwfile
  def read_safe
    pwdata_encrypted = File.read @pwfile
    pwdata_dump      = Encryptor.decrypt( pwdata_encrypted, @pwhash )
    @pwdata          = remove_dummy_data( Marshal.load(pwdata_dump) ) || {}
  rescue
    fail NoAccess, 'Could not decrypt/load the password safe!'
  end

  # Tries to encrypt and save the password safe into the pwfile
  def write_safe
    pwdata_dump      = Marshal.dump add_dummy_data( @pwdata || {} )
    pwdata_encrypted = Encryptor.encrypt pwdata_dump, @pwhash
    File.open( @pwfile, 'w' ){ |f| f.write pwdata_encrypted }
  rescue
    fail NoAccess, 'Could not encrypt/safe the password safe!'
  end
  
  # Checks if the file is accessible or create a new one
  def access_safe
    if !File.file? @pwfile
      puts "No password safe detected, creating one at #@pwfile"
      FileUtils.touch @pwfile
      @pwhash = Encryptor.hash ask_for_password 'please enter a new master password'
      write_safe
    else
      @pwhash = Encryptor.hash ask_for_password 'master password'
    end
  rescue
    raise NoAccess, "Could not access the password safe at #@pwfile!"
  end

  # Adds some redundancy
  def add_dummy_data(pwdata)
    (5000 - pwdata.size).abs.times.map{ rand 42424242 } + # or whatever
      [pwdata]
  end

  def remove_dummy_data(pwdata)
    pwdata.last
  end

  # Prompts the user for a password
  def ask_for_password(prompt = 'new password')
    print "#{prompt}: ".capitalize
    system 'stty -echo'                    # no more terminal output
    pw_plaintext = ($stdin.gets||'').chop  # gets without $stdin would mistakenly read_safe from ARGV
    system 'stty echo'                     # restore terminal output
    puts

    pw_plaintext
  end

  class << Encryptor = Module.new
    CIPHER = 'aes-256-cbc'

    def decrypt( iv_and_data, pwhash )
      iv, data = iv_and_data[0,16], iv_and_data[16..-1]
      crypt :decrypt, data, pwhash, iv
    end

    def encrypt( data, pwhash )
      iv = random_iv
      encrypted_data = crypt :encrypt, data, pwhash, iv
      iv + encrypted_data
    end

    def hash( plaintext )
      OpenSSL::Digest::SHA512.new( plaintext ).digest
    end

    # you need a random iv for cbc mode. It is prepended to the encrypted text.
    def random_iv
      a = OpenSSL::Cipher.new CIPHER
      a.random_iv
    end

    private

    # Encrypts or decrypts the data with the password hash as key
    # NOTE: encryption exceptions do not get caught!
    def crypt( decrypt_or_encrypt, data, pwhash, iv )
      c = OpenSSL::Cipher.new CIPHER
      c.send decrypt_or_encrypt.to_sym
      c.key = pwhash
      c.iv  = iv
      c.update( data ) << c.final
    end
  end
end

# Command line action
if standalone? # using zucker/kernel (instead of __FILE__ == $0)
  if $*.empty?
    action = :show
    args   = []
  else
    action = $*.shift[/^-{0,2}(.*)$/, 1].to_sym # also accept first argument, if it is prefixed with - or --
    args   = [*$*]
  end

  begin
    case action
    when :h, :help, :commands
      puts %q{Available commands
  s/show/list             shows all available entry names
  g/get/entry( name, seconds = 20 )
                          copies the password of the entry into the clipboard
  d/description( names )  shows a description for the password entries
  a/add/set/create( name, description = nil, password = nil )
                          creates or updates an entry. second parameter is a
                          description. third parameter can be a password, but
                          it's recommended to not use it and enter it, when prompted
  gen/generate( name, description = nil, length=128, chars = (32..126).map(&:chr) )
                          creates or updates an entry, but generates a new 
                          random password. you can customize the length and
                          used characters
  r/remove/delete( name ) deletes an password entry
  m/master                changes the master password
  v/version               displays version
  h/help/commands         displays this help}
    when :v, :version
      puts "pws #{PasswordSafe::VERSION}\n J-_-L"
    else # redirect to safe
      if PasswordSafe.public_instance_methods(false).include?(
          if RubyVersion.is?(1.8) then action.to_s else action end ) # using zucker/version

        pws = PasswordSafe.new
        pws.send action, *args
      else
        puts "Unknown command: #{action}. Use 'help' to get a command list!"
      end
    end

  rescue PasswordSafe::NoAccess => e
    warn e.message
  end
end

# J-_-L
