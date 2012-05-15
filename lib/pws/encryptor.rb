require 'openssl'

module PWS::Encryptor
  class << self
    CIPHER = 'aes-256-cbc'
    
    def decrypt(data, options = {})
      crypt(
        :decrypt,
        data,
        options[:hash],
        options[:iv],
      )
    end
    
    def encrypt(data, options = {} )
      iv = random_iv
      encrypted_data = crypt :encrypt, data, pwhash, iv
      iv + encrypted_data
    end
    
    private
    
    # you need a random iv for cbc mode. It is prepended to the encrypted text.
    def random_iv
      a = OpenSSL::Cipher.new(CIPHER)
      a.random_iv
    end
    
    # Encrypts or decrypts the data with the password hash as key
    # NOTE: encryption exceptions do not get caught here!
    def crypt(decrypt_or_encrypt, data, hash, iv)
      c = OpenSSL::Cipher.new(CIPHER)
      c.send(decrypt_or_encrypt.to_sym)
      c.key = hash
      c.iv  = iv
      c.update(data) << c.final
    end
  end
end
