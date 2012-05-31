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

On MacOS, the KDF might be generated pretty slow. You can work around this issue by using less iterations (see help) or [solving this problem](https://github.com/janlelis/pws/issues/7).

Updating from 0.9
---
The 0.9 password files are not compatible with that version, however, you can convert your safe with:
`$ pws resave --in 0.9 --out 1.0`


Reading the source
---
Trust the code by reading the source! It's originally based on [this tutorial](http://rbjl.net/41-tutorial-build-your-own-password-safe-with-ruby). You might want to start reading in the [0.9.2 tag](https://github.com/janlelis/pws/tree/0.9.2), because it's got less features and therefore is less code.


Contributions by
---
* [namelessjon](https://github.com/namelessjon)
* [brianewing](https://github.com/brianewing/)
* [dquimper](https://github.com/dquimper/)
* [grapz](https://github.com/grapz/)
* Cucumber specs loosely based on [the ones](https://github.com/thecatwasnot/passwordsafe/blob/master/features/) by [thecatwasnot](https://github.com/thecatwasnot/)


Copyright
---
© 2010-2012 Jan Lelis, MIT license
