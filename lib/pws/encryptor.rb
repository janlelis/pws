require 'openssl'

module PWS::Encryptor
  class << self
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
    # NOTE: encryption exceptions do not get caught here!
    def crypt( decrypt_or_encrypt, data, pwhash, iv )
      c = OpenSSL::Cipher.new CIPHER
      c.send decrypt_or_encrypt.to_sym
      c.key = pwhash
      c.iv  = iv
      c.update( data ) << c.final
    end
  end
end
