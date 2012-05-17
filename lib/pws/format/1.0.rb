# encoding: ascii

require_relative '../format'
require 'securerandom'
require 'digest/hmac'
require 'openssl'

class PWS
  module Format
    # PWS file format for versions ~> 1.0.0
    # see at bottom block for a format description
    module V1_0
      TEMPLATE = 'A64 A16 L> A64 A*'
      MAX_ITERATIONS     = 4_294_967_296
      DEFAULT_ITERATIONS =       100_000
    
      class << self
        def write(application_data, options = {})
          encrypt(marshal(application_data), options)
        end
        
        def read(encrypted_data, options = {})
          unmarshal(decrypt(encrypted_data, options))
        end
        
        def encrypt(unencrypted_data, options = {})
          raise ArgumentError, 'No password given' if \
              !options[:password]
        
          iterations = options[:iterations] || DEFAULT_ITERATIONS
          salt = SecureRandom.random_bytes(64)
          
          encryption_key, hmac_key = kdf(
            options[:password],
            salt,
            iterations,
          ).unpack('A256 A256')
          
          iv  = Encryptor.random_iv
          sha = hmac(hmac_key, salt, iv, iterations, unencrypted_data)
          
          encrypted_data = Encryptor.encrypt(
            unencrypted_data,
            key: encryption_key,
            iv:  iv,
          )
          
          raise ArgumentError, 'Invalid arguments for building the password file given' if \
              iterations > MAX_ITERATIONS ||
              iv.size != 16               ||
              encrypted_data.empty?
          [salt, iv, iterations, sha, encrypted_data].pack(TEMPLATE) 
        end
        
        def decrypt(saved_data, options = {})
          raise ArgumentError, 'No password given' if \
              !options[:password]
          salt, iv, iterations, sha, encrypted_data = saved_data.unpack(TEMPLATE)
          
          raise NoAccess, 'Password file invalid' if \
              salt.size != 64             ||
              iterations > MAX_ITERATIONS ||
              iv.size != 16               ||
              sha.size != 64              ||
              encrypted_data.empty?
              
          encryption_key, hmac_key = kdf(
            options[:password],
            salt,
            iterations,
          ).unpack('A256 A256')
          
          begin
            unencrypted_data = Encryptor.decrypt(
              encrypted_data,
              key: encryption_key,
              iv:  iv,
            )
          rescue OpenSSL::Cipher::CipherError
            raise NoAccess, 'Could not decrypt'
          end
          
          raise NoAccess, 'Password file intergrity could not be verified' unless \
              sha == hmac(hmac_key, salt, iv, iterations, unencrypted_data)
              
          unencrypted_data
        end
        
        def marshal(application_data, options = {})
          res = []
          number_of_dummies = 8000 + SecureRandom.random_number(4000)
          res << number_of_dummies.to_s << "\n"
        end
        
        def unmarshal(saved_data, options = {})
          Marshal.load(saved_data)
        end
        
        def marshal(application_data, options = {})
          Marshal.dump(application_data)
        end
        
        def unmarshal(saved_data, options = {})
          Marshal.load(saved_data)
        end
        
        private
        
        def kdf(password, salt, iterations)
          OpenSSL::PKCS5::pbkdf2_hmac(
            password,
            salt,
            iterations,
            512,
            OpenSSL::Digest::SHA512.new,
          )
        end
        
        def hmac(key, *strings)
          Digest::HMAC.new(key, Digest::SHA512).update(
            strings.map(&:to_s).join
          ).digest
        end
        
      end#self
    end#V1_0
  end
end

=begin ENCRYPTION FORMAT

Bytes  Data            Description
64     SALT            Randomly generated, used by kdf
16     IV              Randomly generated, used by aes
4      ITERATIONS      How often the password gets hashed by the kdf
64     HMAC            On everything
*      ENCRYPTED_DATA

=end

=begin MARSHAL FORMAT

number of dummy entries before data
dummy entries
names
passwords
timestamps
dummy entries

=end
