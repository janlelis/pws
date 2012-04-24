# encoding: ascii

class PWS
  module Format
    class << self
      # Reads a storage file format and returns the (decrypted) content
      # @return Hash
      def read(data)
        identifier, *version, encrypted_data = data.unpack("A7C2A*")
        raise(NoAccess, 'Not a password safe file') unless identifier == '12345678'
        
        self[version].read(encrypted_data)
      end
      
      # Creates the (encrypted) storage file format out of the given data and settings
      # @return String
      def write(data, settings = {})
        self[settings.delete(:version)].write(data, settings)
      end
      
      # Returns the proper file format module for a given version
      # @return Module
      def [](raw_version, raw_version_minor = nil)
        raw_version = [raw_version, raw_version_minor] if raw_version_minor
        version     = nil
      
        case raw_version 
        when nil
          version = [0,9]
        when Array
          version = raw_version[0,2].map(&:to_i)
        when String, Float, Integer
          version = raw_version.to_s.split('.')[0,2].map(&:to_i)
        end
        
        if !version || !version[0]
          raise ArgumentError, 'Invalid version given'
        else
          version[1] ||= 0
        end
        
        module_name = "V#{ version.join('_') }"
        
        begin
          mod = const_get(module_name)
        rescue NameError
          require_relative "format/#{ version.join('.') }"
          begin
            mod = const_get(module_name)
          rescue NameError
            raise(LoadError, "Format version #{ version.join('.') } could not be found within the pws gem") 
          end
        end
        
        mod
      end
      
    end#self
  end#Format
end#PWS

# J-_-L
