# -*- encoding: utf-8 -*-
name = 'pws'

require File.dirname(__FILE__) + "/lib/#{name}/version"
 
Gem::Specification.new do |s|
  s.required_ruby_version = '>= 1.9.2'
  s.name        = name
  s.version     = PWS::VERSION
  s.authors     = ["Jan Lelis"]
  s.email       = "mail@janlelis.de"
  s.homepage    = 'https://github.com/janlelis/pws'
  s.summary     = "pws is a cli password safe."
  s.description = "pws is a command-line password safe. Please run `pws --help` for usage information."
  s.files = Dir.glob(%w[{lib,test}/**/*.rb bin/* [A-Z]*.{txt,rdoc} ext/**/*.{rb,c} features/**/*]) + %w{Rakefile pws.gemspec}
  s.extra_rdoc_files = ["README.md", "LICENSE"]
  s.license = 'MIT'
  s.executables = ['pws']
  s.add_dependency 'clipboard', '~> 1.0.1'
  s.add_dependency 'zucker',    '>= 12.1'
  s.add_dependency 'paint',     '>= 0.8.4'
  s.add_dependency 'pbkdf2'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'aruba'
  s.add_development_dependency 'cucumber'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'guard-cucumber'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'ripltools'
  s.add_development_dependency 'irbtools'
  # s.add_development_dependency 'ruby-debug19'
  
  len = s.homepage.size
  s.post_install_message = \
   ("       ┌── " + "info ".ljust(len-2,'─')                         + "─┐\n" +
    " J-_-L │ "   + s.homepage                                       + " │\n" +
    "       ├── " + "usage ".ljust(len-2,'─')                        + "─┤\n" +
    "       │ "   + "pws --help".ljust(len,' ')                      + " │\n" +
    "       └─"   + '─'*len                                          + "─┘")
end
