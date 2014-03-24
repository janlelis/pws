module PWS::ClassSupport
  def alias_for(m, *aliases)
    aliases.each{ |a|
      class_eval "alias :'#{a}' :'#{m}'"
    }
  end
  alias aliases_for alias_for
end
