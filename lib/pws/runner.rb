require_relative '../pws'

module PWS::Runner
  SINGLE_OPTIONS = Regexp.union *%w[
    cwd
  ].freeze

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
        when /^--(#{SINGLE_OPTIONS})/ # special single options
          options[$1.to_sym] = true
        when /^--/
          # parse option in next iteration
        when /^-([^-].*)$/
          options[:namespace] = $1
        else
          if prev_arg =~ /^--(.+)$/ && SINGLE_OPTIONS !~ opt = $1
            options[opt.to_sym] = arg
          elsif !action
            action = arg.to_sym
          else
            arguments << arg
          end
        end
      }
      
      [action || :show, arguments, options]
    end
    
    # makes the Ruby safe usable from the cli
    def run(action, arguments, options)
      case action
      when :v, :version
        puts "pws #{PWS::VERSION} by " + Paint["J-_-L", :bold] + " <https://github.com/janlelis/pws>"
      when :help, :actions, :commands
        puts(<<HELP)
  
  #{Paint["Usage", :underline]}
  
  #{Paint['pws', :bold]} [-namespace] action [arguments] [--options]
  
  #{Paint["Info", :underline]}
  
  pws allows you to manage passwords in encryted password files (safes). It
  operates on the file specified in the environment variable PWS or on "~/.pws".
  Using a single dash, you can set a namespace that will be appended to the
  filename, e.g. `pws -work show` will operate on "~/.pws-work".
  
  #{Paint["Available Actions", :underline]}
  
  #{Paint['ls', :bold]} / list / show / status ( pattern = nil )
  Lists all available password entries. Optionally takes a regex filter.
  
  #{Paint['get', :bold]} / entry / copy / password / for ( name, seconds = 10 )
  Copies the password for <name> to the clipboard. The second argument specifies,
  how long the password is kept in the clipboard (0 = no deletion).

  #{Paint['add', :bold]} / set / store / create ( name, password = nil )
  Stores a new password entry. The second argument can be the password, but
  it's recommended to not pass it, but enter it interactively.
  
  #{Paint['gen', :bold]} / generate ( name, seconds = 10, length = 64, char_pool )
  Generates a new password for <name> and then copies it to the clipboard, like
  get (the second argument is the time - it gets passed to get). The third
  argument sets the password length. The fourth argument allows you to pass a
  character pool that is used for generating the passwords.
  
  #{Paint['update', :bold]} / update-add ( name, password = nil )
  Updates an existing password entry.
  
  #{Paint['update-gen', :bold]} / update-generate( name, seconds = 10, length = 64, char_pool )
  Updates an existing password entry using the generate method.
  
  #{Paint['rm', :bold]} / remove / del / delete ( name )
  Removes a password entry.
  
  #{Paint['mv', :bold]} / move / rename ( old_name, new_name )
  Renames a password entry.
  
  #{Paint['master', :bold]} ( password = nil )
  Changes the master password.
  
  #{Paint['resave', :bold]} / convert
  Just save the safe. Useful for converting the file format.
  
  #{Paint['v', :bold]} / version
  Displays version and website.
  
  #{Paint['help', :bold]} / actions / commands
  Displays this help.

  #{Paint["Available Options", :underline]}
  
  #{Paint['--in', :bold]}
  Specifies the password file input format. Neccessary to convert 0.9 safes.
  Supported values: 0.9 1.0
  
  #{Paint['--out', :bold]}
  Specifies the password file output format. Ignored for non-writing actions,
  e.g. get. Defaults to the current version.
  Supported values: 1.0
  
  #{Paint['--filename', :bold]}
  Path to the password safe to use. Overrides usual path and any namespaces.
  
  #{Paint['--cwd', :bold]}
  Use a .pws file in the current directory instead of the one specified in
  ENV['PWS'] or with --filename.
  
  #{Paint['--iterations', :bold]}
  Sets the number of sha iterations used to transform your password into the
  encryption key (pbkdf2). A higher number takes longer to compute, but makes
  it harder for attacker to bruteforce your password.
  
  #{Paint['--seconds', :bold]}, #{Paint['--length', :bold]}, #{Paint['--charpool', :bold]} 
  Preset options for specific actions.
  
  #{Paint["ENV Variables", :underline]}
  
  You can use environment variables to customize the default settings of pws.
  Except for PWS (info at top), the following variables can be used:
  
  PWS_SECONDS
  PWS_LENGTH
  PWS_CHARPOOL
  PWS_ITERATIONS

HELP
      else # redirect to safe
        if PWS.public_instance_methods(false).include?(action)
          status = PWS.new(options).public_send(action, *arguments.map{ |a|
            a.unpack('a*')[0] # ignore encoding
          })
          exit(status ? 0 : 2)
        else
          raise ArgumentError, "Unknown action: #{action}\nPlease see `pws --help` for a list of available commands!"
        end
      end
    rescue PWS::NoLegacyAccess
      pa "NO ACCESS", :red, :bold
      pa 'The password safe you are trying to access migth be a version 0.9 password file', :red
      pa 'If this is the case, you will need to convert it to a version 1.0 password file by calling:', :red
      pa 'pws resave --in 0.9 --out 1.0', :red
      exit(3)
    rescue PWS::NoAccess
      # pa $!.message.capitalize, :red, :bold
      pa "NO ACCESS", :red, :bold
      exit(3)
    rescue ArgumentError
      pa $!.message.capitalize, :red
      exit(4)
    rescue Interrupt
      system 'stty echo' if $stdin.tty? # ensure terminal's working
      pa "..canceled", :red
      exit(5)
    end
    
    # exit status codes (not final, yet)
    # 0 Success
    # 2 Successfully run, but operation not successful
    # 3 NoAccess
    # 4 ArgumentError
    # 5 Interrupt
  end
end

# J-_-L
