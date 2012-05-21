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
      DEFAULT_ITERATIONS =       1_000
      MAX_ITERATIONS     = 4_294_967_295
      MAX_ENTRY_LENGTH   = 4_294_967_295
    
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
          number_of_dummy_bytes = 5000 + SecureRandom.random_number(30000)
          ordered_data = application_data.to_a
          [
            number_of_dummy_bytes,
            application_data.size,
            SecureRandom.random_bytes(number_of_dummy_bytes) +
            data_to_string(ordered_data.map{ |_, e| e[:password] }) +
            data_to_string(ordered_data.map{ |e, _| e }) +
            data_to_string(ordered_data.map{ |_, e| e[:timestamp].to_i }) +
            SecureRandom.random_bytes(5000 + SecureRandom.random_number(30000))
          ].pack('L> L> A*')
        end
        
        def unmarshal(saved_data, options = {})
          number_of_dummy_bytes, data_size, raw_data = saved_data.unpack('L> L> A*')
          i = number_of_dummy_bytes
          passwords, names, timestamps = 3.times.map{
            data_size.times.map{
              next_element, i = string_to_data(raw_data, i)
              next_element
            }
          }
          
          Hash[
            names.zip(
              passwords.zip(timestamps).map{ |e,f|
                { password: e, timestamp: f }
              }
            )
          ]
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
        
        def data_to_string(array)
          array.map{ |e|
            e = e.to_s
            s = e.size
            raise(ArgumentError, 'Entry too long') if s > MAX_ENTRY_LENGTH
            [s, e].pack('L> A*')
          }.join
        end
        
        def string_to_data(string, pos)
          next_length = string[pos..pos+4].unpack('L>')[0]
          new_pos = pos + 4 + next_length
          res = string[pos+4...new_pos].unpack('A*')[0]
          
          [res, new_pos]
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

number of dummy bytes before real data
dummy bytes
passwords
names
timestamps
dummy bytes

=end
