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

        def read(encrypted_data, options = {})
          unmarshal(decrypt(encrypted_data, options))
        rescue
          fail NoAccess, %[Could not read the password safe!]
        end
        
        def decrypt(encrypted_data, options = {})
          iv, data = encrypted_data.unpack('A16 A*')
          PWS::Encryptor.decrypt(data,
            hash: hash(options[:password]),
            iv:   iv,
          )
        end
        
        def unmarshal(string_data, options = {})
          raw_data = Marshal.load(string_data)
          data = raw_data[ raw_data[-1] ]             # remove redundancy
          Hash[data.map{ |k,v| [k, { password: v}] }] # patch to new internal format
        end
        
        def hash(plaintext)
          OpenSSL::Digest::SHA512.new(plaintext).digest
        end
        
      end#self
    end#V0_9
  end
end

# J-_-L
