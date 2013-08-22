if Gem.loaded_specs["pbkdf2"].version.to_s == "0.1.0"
  class String
    def xor_impl(other)
      result = "".encode("ASCII-8BIT")
      o_bytes = other.bytes.to_a
      bytes.each_with_index do |c, i|
        result << (c ^ o_bytes[i])
      end
      result
    end
  end
end

