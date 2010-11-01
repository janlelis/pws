require 'openssl'
require 'fileutils'

class PasswordSafe
  VERSION = '0.0.2'.freeze

  def initialize( filename = File.expand_path('~/.pws') )
    @pwfile = filename
    @pwdata = "example data"
    @pwhash = Encryptor.hash 'password'

    access_safe
    read_safe
  end

  private

  # Tries to load and decrypt the password safe from the pwfile
  def read_safe
    pwdata_encrypted = File.read @pwfile
    @pwdata          = Encryptor.decrypt pwdata_encrypted, @pwhash
  end

  # Tries to encrypt and save the password safe into the pwfile
  def write_safe
    pwdata_encrypted = Encryptor.encrypt @pwdata, @pwhash
    File.open( @pwfile, 'w' ){ |f| f.write pwdata_encrypted }
  end
  
  # Checks if the file is accessible or create a new one
  def access_safe
    if !File.file? @pwfile
      puts "No password safe detected, creating one at #@pwfile"
      FileUtils.touch @pwfile
      write_safe
    end
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

if __FILE__ == $0 # test whether it works :)
  pws = PasswordSafe.new 'p2test'
  print 'Enter data to encrypt: '
  pws.instance_variable_set :@pwdata, gets.chop
  pws.send :write_safe

  puts "In safe: " +
    (File.read pws.instance_variable_get :@pwfile).inspect

  pws = PasswordSafe.new 'p2test'
  pws.send :read_safe
  puts "Read from safe: " + pws.instance_variable_get(:@pwdata)
end

# J-_-L