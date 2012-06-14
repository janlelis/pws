pws [![Build status](http://travis-ci.org/janlelis/pws.png)](http://travis-ci.org/janlelis/pws)
===
pws is a command-line password safe/manager written in Ruby.


Usage
---
[![Screenshot](http://rbjl.net/pws-example.png)](http://rbjl.net/60-pws-the-ruby-powered-command-line-password-manager)


Installation
---
You can install pws with
`$ gem install pws`

Run `$ pws --help` for usage information.

On Linux, please make sure you've got `xclip` or `xsel` installed (clipboard).


OpenSSL 1.0
---
You should use a Ruby built with bindings to an openssl version >= 1.0. If not, pws will fall back to a Ruby-only version of the PBKDF2 function. If using openssl 1.0 is not possible for you, you can work around the issue by using the `--iterations` option with a value < 75\_000 (see help). If you have problems using openssl 1.0 with your Ruby, please look for a solution in [this github issue](https://github.com/janlelis/pws/issues/7).


Using a .pws file in the current working directory
---
Besides using the `--filename path/to/safe` option, you can shortly call `pws --cwd` for using a `.pws` file in the current directory.


Updating from pws 0.9
---
The 0.9 password files are not compatible with that version, however, you can convert your safe with:
`$ pws resave --in 0.9 --out 1.0`


Reading the source
---
Trust the code by reading the source! It's originally based on [this tutorial](http://rbjl.net/41-tutorial-build-your-own-password-safe-with-ruby). You might want to start reading in the [0.9.2 tag](https://github.com/janlelis/pws/tree/0.9.2), because it's got less features and therefore is less code.


Contributors
---
* [namelessjon](https://github.com/namelessjon)
* [brianewing](https://github.com/brianewing/)
* [dquimper](https://github.com/dquimper/)
* [grapz](https://github.com/grapz/)
* [thecatwasnot](https://github.com/thecatwasnot/) (cucumber specs loosely based on [these](https://github.com/thecatwasnot/passwordsafe/blob/master/features/))


Copyright
---
© 2010-2012 Jan Lelis, MIT license
