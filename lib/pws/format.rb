# encoding: ascii
require_relative '../pws'

class PWS
  # The purpose of this module is redirecting to the proper format version module
  # It also reads and writes the generic header (identifier + pws version)
  # See for example: pws/format/1.0
  module Format
    class << self
      def read(encrypted_data, options = {})
        if options.delete(:legacy)
          version = 0.9
        else
          version, encrypted_data = preprocess(encrypted_data)
        end
        
        self[version].read(encrypted_data, options)
      end
      
      def preprocess(data, options = {})
        raise(PWS::NoAccess, 'Password file not valid') if data.size <= 10
        identifier, *version, data = data.unpack("A8C2A*")
        raise(PWS::NoAccess, 'Not a password file') unless identifier == '12345678'
        
        [version, data]
      end
      
      # Returns the proper file format module for a given version
      # @return Module
      def [](raw_version, raw_version_minor = nil)
        raw_version = [raw_version, raw_version_minor] if raw_version_minor
        version     = nil
      
        case raw_version 
        when Array
          version = raw_version[0,2]
        when String, Float, Integer
          version = raw_version.to_s.split('.')[0,2]
        when nil
          version = [0,9]
        end
        
        if !version || !version[0]
          raise ArgumentError, 'Invalid version given'
        else
          version[1] ||= 0
          version.map!(&:to_i)
        end

        module_name = "V#{ version.join('_') }"
        
        begin
          mod = const_get(module_name)
        rescue NameError
          begin
            require_relative "format/#{ version.join('.') }"
          rescue LoadError
            raise(PWS::NoAccess, "Format version #{ version.join('.') } could not be found within the pws gem") 
          end
          mod = const_get(module_name)
        end
        
        mod
      end
      
    end#self
  end#Format
end#PWS

# J-_-L
