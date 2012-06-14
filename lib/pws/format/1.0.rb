# encoding: ascii

require_relative '../format'
require 'securerandom'
require 'digest/hmac'
require 'openssl'
require 'pbkdf2'

class PWS
  module Format
    # PWS file format for versions ~> 1.0.0
    # see at bottom block for a short format description
    module V1_0
      TEMPLATE = 'a64 a16 N a64 a*'.freeze
      DEFAULT_ITERATIONS =        75_000
      MAX_ITERATIONS     =    10_000_000
      MAX_ENTRY_LENGTH   = 4_294_967_295 # N
    
      class << self
        def write(application_data, options = {})
          encrypt(marshal(application_data), options)
        end
        
        def encrypt(unencrypted_data, options = {})
          raise ArgumentError, 'No password given' if \
              !options[:password]

          iterations = ( options[:iterations] || DEFAULT_ITERATIONS ).to_i
          raise ArgumentError, 'Invalid iteration count given' if \
              iterations > MAX_ITERATIONS || iterations < 2
          
          salt = SecureRandom.random_bytes(64)
          iv  = Encryptor.random_iv
          
          encryption_key, hmac_key = kdf(
            options[:password],
            salt,
            iterations,
          ).unpack('a256 a256')
          
          sha = hmac(hmac_key, salt, iv, iterations, unencrypted_data)
          
          encrypted_data = Encryptor.encrypt(
            unencrypted_data,
            key: encryption_key,
            iv:  iv,
          )
          
          [salt, iv, iterations, sha, encrypted_data].pack(TEMPLATE) 
        end
        
        def marshal(application_data, options = {})
          number_of_dummy_bytes = 100_000 + SecureRandom.random_number(1_000_000)
          ordered_data = application_data.to_a
          [
            number_of_dummy_bytes,
            application_data.size,
            SecureRandom.random_bytes(number_of_dummy_bytes) +
            array_to_data_string(ordered_data.map{ |_, e| e[:password].to_s }) +
            array_to_data_string(ordered_data.map{ |k, _| k.to_s }) +
            array_to_data_string(ordered_data.map{ |_, e| e[:timestamp].to_i }) +
            SecureRandom.random_bytes(100_000 + SecureRandom.random_number(1_000_000))
          ].pack('N N a*')
        end
        
        # - - -
        
        def read(encrypted_data, options = {})
          unmarshal(decrypt(encrypted_data, options))
        end
        
        def decrypt(saved_data, options = {})
          raise ArgumentError, 'No password given' if \
              !options[:password]
          raise ArgumentError, 'No data given' if \
              !saved_data || saved_data.empty?
          salt, iv, iterations, sha, encrypted_data = saved_data.unpack(TEMPLATE)
          
          raise NoAccess, 'Password file invalid' if \
              salt.size != 64             ||
              iterations > MAX_ITERATIONS ||
              iv.size != 16               ||
              sha.size != 64
              
          encryption_key, hmac_key = kdf(
            options[:password],
            salt,
            iterations,
          ).unpack('a256 a256')
          
          begin
            unencrypted_data = Encryptor.decrypt(
              encrypted_data,
              key: encryption_key,
              iv:  iv,
            )
          rescue OpenSSL::Cipher::CipherError
            raise NoAccess, 'Could not decrypt'
          end
          
          raise NoAccess, 'Password file invalid' unless \
              sha == hmac(hmac_key, salt, iv, iterations, unencrypted_data)
              
          unencrypted_data
        end
        
        def unmarshal(saved_data, options = {})
          number_of_dummy_bytes, data_size, raw_data = saved_data.unpack('N N a*')
          i = number_of_dummy_bytes
          passwords, names, timestamps = 3.times.map{
            data_size.times.map{
              next_element, i = get_next_data_string(raw_data, i)
              next_element
            }
          }
          Hash[
            names.zip(
              passwords.zip(timestamps).map{ |e,f|
                { password: e.to_s, timestamp: f.to_i }
              }
            )
          ]
        end
        
        # support
        
        def hmac(key, *strings)
          Digest::HMAC.new(key, Digest::SHA512).update(
            strings.map(&:to_s).join
          ).digest
        end
        
        def kdf_openssl(password, salt, iterations)
          OpenSSL::PKCS5::pbkdf2_hmac(
            password,
            salt,
            iterations,
            512,
            OpenSSL::Digest::SHA512.new,
          )
        end
        
        def kdf_ruby(password, salt, iterations)
          PBKDF2.new(
            password: password,
            salt: salt,
            iterations: iterations,
            key_length: 512,
            hash_function: OpenSSL::Digest::SHA512,
          ).bin_string
        end
        
        # see gh#7
        begin
          OpenSSL::PKCS5::pbkdf2_hmac("","",2,512,OpenSSL::Digest::SHA512.new)
        rescue NotImplementedError
          alias kdf kdf_ruby
          warn "[pws slow] https://github.com/janlelis/pws#openssl-10"
        else
          alias kdf kdf_openssl
        end
        
        private
        
        def array_to_data_string(array)
          array.map{ |e|
            e = e.to_s
            s = e.bytesize
            raise(ArgumentError, 'Entry too long') if s > MAX_ENTRY_LENGTH
            [s, e].pack('N a*')
          }.join
        end
        
        def get_next_data_string(string, pos)
          res_length = string[pos..pos+4].unpack('N')[0]
          new_pos = pos + 4 + res_length
          res = string[pos+4...new_pos].unpack('a*')[0]
          
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
