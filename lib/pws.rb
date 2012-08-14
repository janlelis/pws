# encoding: ascii
require_relative 'pws/version'
require_relative 'pws/encryptor'
require_relative 'pws/format'

require 'fileutils'
require 'securerandom'
require 'abbrev'

require 'clipboard'
require 'zucker/alias_for'
require 'paint/pa'

class PWS
  class NoAccess < StandardError; end
  class NoLegacyAccess < NoAccess; end
  
  attr_reader :filename
  
  # Creates a new password safe. Takes the path to the password file, by default: ~/.pws
  # Second parameter allows namespaces that get appended to the file name (uses another safe) 
  # You can pass the master password as third parameter (not recommended)
  def initialize(options)
    collect_options(options)
    @filename = @options[:cwd] ? File.join(FileUtils.pwd, '.pws') : File.expand_path(@options[:filename])
    @filename << '-' << @options[:namespace] if @options[:namespace]
    
    read_safe(options[:password])
  end
  
  # Shows a password entry list
  def show(pattern = nil)
    if @data.empty? 
      pa %[There aren't any passwords stored at #{@filename}, yet], :red
    else
      if pattern
        keys = @data.keys.grep /#{pattern}/
      else
        keys = @data.keys
      end
      
      if keys.empty?
        pa %[No passwords found for pattern /#{pattern}/], :red
      else
        puts Paint["Entries", :underline] + %[ in ] + @filename
        longest_key_size = keys.max_by(&:size).size
        puts keys.sort.map{ |key|
          "- #{
            Paint[key, :bold]
          } #{ 
            Time.at(@data[key][:timestamp].to_i).strftime('%y-%m-%d') if @data[key][:timestamp].to_i != 0
          }\n"
        }.join
      end
    end
    return true
  rescue RegexpError
    raise ArgumentError, %[Invalid regex given]
  end
  aliases_for :show, :ls, :list, :status
  
  # Add a password entry, params: name, password (optional, opens prompt if not given)
  def add(key, password = nil)
    if @data[key]
      pa %[There is already a password stored for #{key}. You need to remove it before creating a new one!], :red
      return false
    else
      @data[key] = {}
      @data[key][:password] = password || ask_for_password(%[please enter a password for #{key}], :yellow)
      if @data[key][:password].empty?
        raise ArgumentError, %[Cannot set an empty password!]
      else
        @data[key][:timestamp] = Time.now.to_i
        write_safe
        pa %[The password for #{key} has been added], :green
        return true
      end
    end
  end
  aliases_for :add, :set, :store, :create
  
  # Updates a password entry, params: name, password (optional, opens prompt if not given)
  def update(key, password = nil)
    if !@data[key]
      pa %[There is no password stored for #{key}, so you cannot update it!], :red
      return false
    else
      @data[key][:password] = password || ask_for_password(%[please enter a new password for #{key}], :yellow)
      if @data[key][:password].empty?
        raise ArgumentError, %[Cannot set an empty password!]
      else
        @data[key][:timestamp] = Time.now.to_i
        write_safe
        pa %[The password for #{key} has been updated], :green
        return true
      end
    end
  end
  alias :'update-add' :update
  
  # Gets the password entry and copies it to the clipboard. The second parameter is the time in seconds it stays there
  def get(key, seconds = @options[:seconds])
    if real_key = @abbrevs[key]
      password = @data[real_key][:password]
      if seconds && seconds.to_i > 0
        original_clipboard_content = Clipboard.paste
        Clipboard.copy password
        pa %[The password for #{real_key} is now available in your clipboard for #{seconds.to_i} second#{?s if seconds.to_i > 1}], :green
        begin
          sleep seconds.to_i
        rescue Interrupt
          Clipboard.copy original_clipboard_content
          raise
        end
        Clipboard.copy original_clipboard_content
        return true
      else
        Clipboard.copy password
        pa %[The password for #{real_key} has been copied to your clipboard], :green
        return true
      end
    else
      pa %[No password found for #{key}!], :red
      return false
    end
  end
  aliases_for :get, :entry, :copy, :password, :for, :[]
  
  # Adds a password entry with a freshly generated random password
  def generate(
        key,
        seconds   = @options[:seconds],
        length    = @options[:length],
        charpool  = @options[:charpool]
    )
    get(key, seconds) if add(key, generator(length, charpool))
  end
  alias_for :generate, :gen
  
  # Updates a password entry with a freshly generated random password
  def update_generate(
        key,
        seconds   = @options[:seconds],
        length    = @options[:length],
        charpool  = @options[:charpool]
    )
    get(key, seconds) if update(key, generator(length, charpool))
  end
  alias :'update-generate' :update_generate
  alias :'update_gen'      :update_generate
  alias :'update-gen'      :update_generate
  
  # Removes a specific password entry
  def remove(key)
    if @data.delete key
      write_safe
      pa %[The password for #{key} has been removed], :green
      return true
    else
      pa %[No password found for #{key}!], :red
      return false
    end
  end
  aliases_for :remove, :rm, :del, :delete
  
  # Removes a specific password entry
  def rename(old_key, new_key)
    if !@data[old_key]
      pa %[No password found for #{old_key}!], :red
      return false
    elsif @data[new_key]
      pa %[There is already a password stored for #{new_key}. You need to remove it before naming another one #{new_key}!], :red
      return false
    else
      @data[new_key] = @data.delete(old_key)
      write_safe
      pa %[The password entry #{old_key} has been renamed to #{new_key}], :green
      return true
    end
  end
  aliases_for :rename, :mv, :move
  
  # Changes the master password
  def master(password = nil)
    unless @password = password
      new_password = ask_for_password(%[please enter the new master password], :yellow, :bold)
      @password    = ask_for_password(%[please enter the new master password, again], :yellow, :bold)
      if new_password != @password
        raise ArgumentError, %[The passwords don't match!]
      end
    end
    write_safe
    pa %[The master password has been changed], :green
    return true
  end
  
  # Just writes the safe, useful for converting with --in and --out
  def resave
    write_safe
    pa %[The password file has been resaved], :green
    return true
  end
  alias_for :resave, :convert
  
  # Prevents accidental displaying, e.g. in irb
  def to_s
    %[#<password safe>]
  end
  alias_for :to_s, :inspect
  
  private

  def collect_options(options = {})
    @options = options
    @options[:filename]   ||= ENV["PWS"]            || '~/.pws'
    @options[:seconds]    ||= ENV['PWS_SECONDS']    || 10
    @options[:length]     ||= ENV['PWS_LENGTH']     || 64
    @options[:charpool]   ||= ENV['PWS_CHARPOOL']   || (33..126).map(&:chr).join
    @options[:in]         ||= ENV['PWS_FORMAT']     || VERSION
    @options[:out]        ||= ENV['PWS_FORMAT']     || VERSION
    @options[:iterations] ||= ENV['PWS_ITERATIONS'] || 75_000
  end
  
  # Checks if the file is accessible or create a new one
  # Tries to load and decrypt the password safe from the pwfile
  def read_safe(password = nil)
    if File.file?(@filename)
      print %[Access password safe at #@filename | ]
      @password = password || ask_for_password(%[master password])
      encrypted_data = File.read(@filename)
      
      @data = Format.read(
        encrypted_data,
        password: @password,
        format: @options[:in],
      )
      update_abbrevs!
    else
      create_safe(password)
    end 

    pa %[ACCESS GRANTED], :green
  end
  
  
  # Tries to encrypt and save the password safe into the pwfile
  def write_safe
    encrypted_data = Format.write(
      @data,
      password: @password,
      format: @options[:out],
      iterations: @options[:iterations],
    )
    File.open(@filename, 'w'){ |f| f.write(encrypted_data) }
    update_abbrevs!
  end
  
  def create_safe(password = nil)
    pa %[No password safe detected, creating one at #@filename], :blue, :bold
    unless @password = password
      new_password = ask_for_password(%[please enter the new master password], :yellow, :bold)
      @password    = ask_for_password(%[please enter the new master password, again], :yellow, :bold)
      if new_password != @password
        raise ArgumentError, %[The passwords don't match!]
      end
    end
    
    FileUtils.mkdir_p(File.dirname(@filename))
    @data = {}
    write_safe
    File.chmod(0600, @filename)
  end
  
  # Prompts the user for a password
  def ask_for_password(prompt = 'new password', *colors)
    print Paint["#{prompt}:".capitalize, *colors] + " "
    system 'stty -echo' if $stdin.tty?     # no more terminal output
    password = ($stdin.gets||'').chop      # gets without $stdin would mistakenly read_safe from ARGV
    system 'stty echo'  if $stdin.tty?     # restore terminal output
    puts "\e[999D\e[K\e[1A" if $stdin.tty? # re-use prompt line in terminal
    
    password
  end
  
  # Generate a random password, maybe put in its own class sometime
  def generator(length, charpool)
    charpool_size = charpool.size
    (1..length.to_i).map{
      charpool[SecureRandom.random_number(charpool_size)]
    }.join
  end

  def update_abbrevs!
     @abbrevs = @data.keys.abbrev
  end
end

# Command line behavior in pws/runner.rb

# J-_-L
