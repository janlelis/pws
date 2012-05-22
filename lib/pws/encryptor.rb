require 'openssl'

# This encryptor class wraps around openssl to simplify
# en/decryption using AES 256 CBC
# Please note: Failed en/decryptions will raise errors
module PWS::Encryptor
  class << self
    CIPHER = 'aes-256-cbc'
    
    def decrypt(encrypted_data, options = {})
      crypt(
        :decrypt,
        encrypted_data,
        options[:key],
        options[:iv],
      )
    end
    
    def encrypt(unecrypted_data, options = {})
      crypt(
        :encrypt,
        unecrypted_data,
        options[:key],
        options[:iv],
      )
    end
    
    def random_iv
      OpenSSL::Cipher.new(CIPHER).random_iv
    end
    
    private
    
    # Encrypts or decrypts the data with the password hash as key
    # NOTE: encryption exceptions do not get caught here!
    def crypt(decrypt_or_encrypt, data, key, iv)
      c = OpenSSL::Cipher.new(CIPHER)
      c.send(decrypt_or_encrypt.to_sym)
      c.key = key
      c.iv  = iv
      c.update(data) << c.final
    end
  end
end
