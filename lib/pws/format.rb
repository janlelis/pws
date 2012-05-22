# encoding: ascii
require_relative '../pws'

class PWS
  # The purpose of this module is redirecting to the proper format version module
  # It also reads and writes the generic header (identifier + pws version)
  # See for example: pws/format/1.0
  module Format
    class << self
      def read(saved_data, options = {})
        raise ArgumentError, 'No password file given' unless saved_data
        
        if options.delete(:legacy)
          version = 0.9
          encrypted_data = saved_data
        else
          raise(PWS::NoAccess, 'Password file not valid') if \
              saved_data.size <= 11
          identifier, *version, encrypted_data =
              saved_data.unpack("a8 C2 x a*")
          raise(PWS::NoAccess, 'Password file not valid') unless \
              identifier == '12345678'
        end
        
        self[options.delete(:version) || version].read(encrypted_data, options)
      end
      
      def write(application_data, options)
        version = options.delete(:version) || PWS::VERSION
        
        [
          '12345678',
          *version_to_array(version),
          self[version].write(application_data, options),
        ].pack('a8 C2 x a*')
      end
      
      # Returns the proper file format module for a given version
      # @return Module
      def [](raw_version, raw_version_minor = nil)
        version = version_to_array(raw_version, raw_version_minor)

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
      
      # converts various version formats into an array of two integers
      def version_to_array(raw_version, raw_version_minor = nil)
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
        
        if !version || !version.is_a?(Array) || !version[0]
          raise ArgumentError, 'Invalid version given'
        else
          version[1] ||= 0
          version.map!(&:to_i)
        end
        
        version
      end
      
    end#self
  end#Format
end#PWS

# J-_-L
