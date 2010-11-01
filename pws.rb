require 'rubygems' if RUBY_VERSION[2] == ?8

require 'openssl'
require 'fileutils'
require 'clipboard'         # gem install clipboard
require 'zucker/alias_for'  # gem install zucker
require 'zucker/egonil'
require 'zucker/kernel'

class PasswordSafe
  VERSION = "0.0.3".freeze

  Entry = Struct.new :description, :password

  def initialize( filename = File.expand_path('~/.pws') )
    @pwfile = filename

    access_safe
    read_safe
  end

  def add(key, description = nil, password = nil)
    @pwdata[key]             = Entry.new
    @pwdata[key].password    = password || ask_for_password( "please enter a password for #{key}" )
    @pwdata[key].description = description
    write_safe
  end
  aliases_for :add, :a, :set, :create, :update, :[]= # using zucker/alias_for

  def get(key)
    if pw_plaintext = @pwdata[key] && @pwdata[key].password
      Clipboard.copy pw_plaintext
      puts "The password has been copied to your clipboard"
    else
      puts "No password entry found for #{key}"
    end
  end
  aliases_for :get, :g, :entry, :[]

  def remove(key)
    if @pwdata.delete key
      puts "#{key} has been removed"
    else
      puts "Nothing removed"
    end
  end
  aliases_for :remove, :r, :delete

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

  def description(*keys)
    keys.each{ |key|
      puts (@pwdata[key] && @pwdata[key].description) || key
    }
  end

  def master
    @pwhash = Encryptor.hash ask_for_password 'please enter a new master password'
    write_safe
  end
  aliases_for :master, :m

  private

  # Tries to load and decrypt the password safe from the pwfile
  def read_safe
    pwdata_encrypted = File.read @pwfile
    pwdata_dump      = Encryptor.decrypt( pwdata_encrypted, @pwhash )
    @pwdata          = Marshal.load(pwdata_dump) || {}
  end

  # Tries to encrypt and save the password safe into the pwfile
  def write_safe
    pwdata_dump      = Marshal.dump @pwdata || {}
    pwdata_encrypted = Encryptor.encrypt pwdata_dump, @pwhash
    File.open( @pwfile, 'w' ){ |f| f.write pwdata_encrypted }
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
  end

  def ask_for_password(prompt = 'new password')
    print "#{prompt}: ".capitalize
    system 'stty -echo'                    # no more terminal output
    pw_plaintext = ($stdin.gets||'').chop  # gets without $stdin would mistakenly read_safe from ARGV
    system 'stty echo'                     # restore terminal output
    puts

    pw_plaintext
  end

  class << Encryptor = Module.new
    CIPHER = 'AES256'

    def decrypt( data, pwhash )
      crypt :decrypt, data, pwhash
    end

    def encrypt( data, pwhash )
      crypt :encrypt, data, pwhash
    end

    def hash( plaintext )
      OpenSSL::Digest::SHA512.new( plaintext ).digest
    end

    private

    # Encrypts or decrypts the data with the password hash as key
    # NOTE: encryption exceptions do not get caught!
    def crypt( decrypt_or_encrypt, data, pwhash )
      c = OpenSSL::Cipher.new CIPHER
      c.send decrypt_or_encrypt.to_sym
      c.key = pwhash
      c.update( data ) << c.final
    end
  end
end

if standalone? # using zucker/kernel (instead of __FILE__ == $0)
  pws = PasswordSafe.new 'p3test'
  pws.send $*.shift.to_sym, *$*
end