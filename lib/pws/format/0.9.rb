# encoding: ascii
require_relative '../format'
require 'openssl'

class PWS
  module Format
    # PWS file format reader for versions before 1.0.0
    module V0_9
      class << self
        def write(_,_={})
          raise NotImplementedError, 'Writing the legacy 0.9 format is not supported'
        end

        def read(saved_data, options = {})
          unmarshal(decrypt(saved_data, options))
        rescue
          fail NoAccess, %[Could not read the password safe!]
        end
        
        def decrypt(saved_data, options = {})
          iv, encrypted_data = saved_data.unpack('A16 A*')
          PWS::Encryptor.decrypt(
            encrypted_data,
            key: sha(options[:password]),
            iv:   iv,
          )
        end
        
        def unmarshal(unencrypted_data, options = {})
          raw_data = Marshal.load(unencrypted_data)
          application_data = raw_data[ raw_data[-1] ] # remove redundancy
          Hash[application_data.map{ |k,v| [k, { password: v}] }] # patch to new internal format
        end
        
        def sha(plaintext)
          OpenSSL::Digest::SHA512.new(plaintext).digest
        end
        
      end#self
    end#V0_9
  end
end

# J-_-L
