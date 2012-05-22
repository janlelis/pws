require_relative '../pws'

module PWS::Runner
  class << self
    # some simple option parsing
    # returns action, arguments, options
    # only accepts options with value as next arg, except breaking special cases
    def parse_cli_arguments(argv = $*.dup)
      action    = nil
      options   = {}
      arguments = []
      argv.unshift(nil) # easier parsing
      
      argv.each_cons(2){ |prev_arg, arg|
        case arg
        when '-'
          # ignore
        when /^--(help|version)$/
          return [$1.to_sym, [], {}]
        when /^--(legacy)$/
          options[:legacy] = true
        when /^--/
          # parse option in next iteration
        when /^-([^-].*)$/
          options[:namespace] = $1
        else
          if prev_arg =~ /^--(.+)$/
            options[$1.to_sym] = arg
          elsif !action
            action = arg.to_sym
          else
            arguments << arg
          end
        end
      }
      
      [action || :show, arguments, options]
    end
    
    # makes the Ruby safe more usable
    def run(action, arguments, options)
      case action
      when :v, :version
        puts "pws #{PWS::VERSION} by " + Paint["J-_-L", :bold] + " <https://github.com/janlelis/pws>"
      when :help, :actions, :commands
        puts(<<HELP)
  
  #{Paint["Usage", :underline]}
  
  #{Paint['pws', :bold]} [-namespace] action [arguments]
  
  #{Paint["Info", :underline]}
  
  pws allows you to manage passwords in encryted password files (safes). It
  operates on the file specified in the environment variable PWS or on "~/.pws".
  You can apply a namespace as first parameter that will be appended to the
  filename, e.g. `pws -work show` with usual env would use "~/.pws-work".
  
  #{Paint["Available actions", :underline]}
  
  #{Paint['ls', :bold]} / list / show / status ( pattern = nil )
  Lists all available password entries. Optionally takes a regex filter.
  
  #{Paint['add', :bold]} / set / store / create ( name, password = nil )
  Stores a new password entry. The second argument can be the password, but
  it's recommended to not pass it, but enter it interactively.
  
  #{Paint['get', :bold]} / entry / copy / password / for ( name, seconds = 10 )
  Copies the password for <name> to the clipboard. The second argument specifies,
  how long the password is kept in the clipboard (0 = no deletion).
  
  #{Paint['gen', :bold]} / generate ( name, seconds = 10, length = 64, char_pool )
  Generates a new password for <name> and then copies it to the clipboard, like
  get (the second argument is the time - it gets passed to get). The third
  argument sets the password length. The fourth argument allows you to pass a
  character pool that is used for generating the passwords.
  
  #{Paint['rm', :bold]} / remove / del / delete ( name )
  Removes a password entry.
  
  #{Paint['mv', :bold]} / move / rename ( old_name, new_name )
  Renames a password entry.
  
  #{Paint['master', :bold]} ( password = nil )
  Changes the master password.
  
  #{Paint['v', :bold]} / version
  Displays version and website.
  
  #{Paint['help', :bold]} / actions / commands
  Displays this help.
  
HELP
      else # redirect to safe
        if PWS.public_instance_methods(false).include?(action)
          PWS.new(options).public_send(action, *arguments)
        else
          pa "Unknown action: #{action}\nPlease see `pws --help` for a list of available commands!", :red
        end
      end
    #rescue PWS::NoAccess
    #   pa $!.message.capitalize, :red, :bold
    #  pa "NO ACCESS", :red, :bold
  #  rescue ArgumentError
   #   pa $!.message.capitalize, :red
    rescue Interrupt
      system 'stty echo' if $stdin.tty? # ensure terminal's working
      pa "..canceled", :red
    end
  end
end

# J-_-L
