# encoding: ascii
require_relative '../pws'

class PWS
  # The purpose of this module is redirecting to the proper format version module
  # It also reads and writes the generic header (identifier + pws version)
  # Format module can be specified by two integers, support for symbols may be
  # added sometime to support special formats
  # See for example: pws/format/1.0
  module Format
    IN  = [[0,9], [1,0], [1,1]]
    OUT = [[1,1]]

    class << self
      def read(saved_data, options = {})
        raise ArgumentError, 'No password file given' unless saved_data
        format = normalize_format(options.delete(:format))

        if format && !IN.include?(format)
          raise ArgumentError, "Input format <#{format.join('.')}> is not supported"
        end

        if format == [0,9]
          encrypted_data = saved_data
        else
          raise(PWS::NoAccess, 'Password file not valid') if \
              saved_data.size <= 11
          identifier, *file_format, encrypted_data =
              saved_data.unpack("a8 C2 x a*")
          raise(PWS::NoLegacyAccess, 'Password file not valid') unless \
              identifier == '12345678'
          format ||= normalize_format(file_format) # --in option wins againts read file_format

          if !IN.include?(format)
            raise PWS::NoAccess, "Input format <#{format.join('.')}> is not supported"
          end
        end


        self[format].read(encrypted_data, options)
      end

      def write(application_data, options)
        format = normalize_format(options.delete(:format) || PWS::VERSION)

        raise ArgumentError, "Output format <#{format.join('.')}> is not supported" \
            unless OUT.include?(format)

        [
          '12345678',
          *format,
          self[format].write(application_data, options),
        ].pack('a8 C2 x a*')
      end

      # Returns the proper file format module for a given format identifier
      # @return Module
      def [](format)
        error_message = 'Can only find format modules for symbols or arrays with exactly two integers'
        case format
        when Array
          raise ArgumentError, error_message unless \
              format.size == 2 && format[0].is_a?(Integer) && format[1].is_a?(Integer)
          require_relative "format/#{ format.join('.') }"
          module_name = "V#{ format.join('_') }"
          return const_get(module_name)
        when Symbol
          require_relative "format/#{ format.to_s.gsub(/[^a-z_]/,'') }"
          return const_get(format.capitalize)
        end

        raise ArgumentError, error_message
      end

      # Converts various version formats into an array of two integers
      # Symbols won't be changed
      def normalize_format(raw_format)
        case raw_format
        when Symbol
          return raw_format
        when Array
          format = raw_format[0,2]
        when String, Float, Integer
          format = raw_format.to_s.split('.')[0,2]
        when nil
          return nil
        end

        if !format || !format.is_a?(Array) || !format[0]
          raise ArgumentError, 'Invalid format given'
        else
          format.map!(&:to_i)
          format[1] ||= 0
        end

        format
      end

    end#self
  end#Format
end#PWS

# J-_-L
