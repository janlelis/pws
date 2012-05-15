# encoding: ascii
require_relative '../format'
require 'openssl'

class PWS
  module Format
    # PWS file format for versions before 1.0.0
    module V0_9
      class << self
        def read(encrypted_data, options = {})
          encrypted_data = encrypted_data.force_encoding("ascii")
          iv, data = encrypted_data[0,16], encrypted_data[16..-1]
          dumped_data = PWS::Encryptor.decrypt(data,
            hash: hash(options[:password]),
            iv:   iv,
          )
          data_with_redundancy = Marshal.load(dumped_data)
          data = remove_redundancy(data_with_redundancy)
          
          data
        rescue
          fail NoAccess, %[Could not read the password safe!]
        end
        
        def write(data, options = {})
          data_with_redundancy = add_redundancy(data || {})
          dumped_data = Marshal.dump(data)
          encrypted_data = PWS::Encryptor.encrypt(dumped_data, options[:password])
          
          encrypted_data
        end
        
        def hash(plaintext)
          OpenSSL::Digest::SHA512.new(plaintext).digest
        end
        
        def encrypt
        end
        
        def decrypt
        end
        
        private
        
        # Adds some redundancy (to conceal how much you have stored)
        def add_redundancy(data)
          entries  = 8000 + SecureRandom.random_number(4000)
          position = SecureRandom.random_number(entries)
          
          ret = entries.times.map{ # or whatever... just create noise ;)
            { SecureRandom.uuid.chars.to_a.shuffle.join => SecureRandom.uuid.chars.to_a.shuffle.join }
          }
          ret[position] = data
          ret << position
          
          ret
        end
        
        # And remove it
        def remove_redundancy(data)
          position = data[-1]
          data[position]
        end
        
      end#self
    end#V0_9
  end
end

# J-_-L
