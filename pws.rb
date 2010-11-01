require 'openssl'

class PasswordSafe
  VERSION = '0.0.1'.freeze
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

# Example
if __FILE__ == $0
  a = "data"
  b = Encryptor.hash 'password'
  c = Encryptor.encrypt a, b
  puts 'Encrypted: ' + c.inspect
  d = Encryptor.decrypt c, b
  puts 'Decrypted: ' + d
end

# J-_-L