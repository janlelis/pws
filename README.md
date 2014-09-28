pws
===
This is a fork of [*pws* by Jan Lelis](https://github.com/janlelis/pws), a command-line password safe/manager written in Ruby using [aes-256-cbc](http://en.wikipedia.org/wiki/Advanced_Encryption_Standard) and [pbkdf2](http://en.wikipedia.org/wiki/PBKDF2).

This version adds the option to store usernames along with passwords. Read below the instructions to update to this version if you have version 1.0 or 0.9 already installed.

Usage
---

* Add new passwords with `$ pws add <key>`. You will be prompted for a username and password that will encrypted and stored in your home directory.
* Retrieve your usernames and passwords with `$ pws get <key>`. The username will be displayed and the password will be copied to your clipboard.

Type `pws help` for complete usage instructions.

Setup
---

To install *pws 1.1* with usernames support you need to clone this repository and create a local gem:

* `$ gem build pws.gemspec`
* `$ gem install pws-1.1.gem`

You can install *pws 1.0* with: `$ gem install pws`

Run `$ pws --help` for usage information.

On Linux, please make sure you've got `xclip` or `xsel` installed (for the clipboard).

Hints
---

### OpenSSL 1.0
You should use a Ruby that was built with bindings to an openssl version >= 1.0 or pws will fall back to a Ruby-only version of the PBKDF2 function, which is much slower. If using openssl 1.0 is not possible for you, you can work around that issue by using the `--iterations` option with a value below 75\_000 (see help). If you have problems using openssl 1.0 with your Ruby, please look for a solution in [this issue](https://github.com/janlelis/pws/issues/7).


### Updating to pws 1.1 with usernames
Password files created with versions < 1.1 are not compatible with version 1.1. However, you can easily convery your safes with:
`$ pws resave --in [0.9|1.0] --out 1.1`


### How to use a .pws file in the current working directory
Besides using the `--filename path/to/safe` option, you can shortly call `pws --cwd` for using a `.pws` file in the current directory.


### Reading the source
Trust the code by reading the source! It's originally based on [this tutorial](http://rbjl.net/41-tutorial-build-your-own-password-safe-with-ruby). You might want to start reading in the [0.9.2 tag](https://github.com/janlelis/pws/tree/0.9.2), because it's got less features and therefore is less code.


Contributors
---
* [namelessjon](https://github.com/namelessjon/)
* [brianewing](https://github.com/brianewing/)
* [dquimper](https://github.com/dquimper/)
* [grapz](https://github.com/grapz/)
* [thecatwasnot](https://github.com/thecatwasnot/) (cucumber specs loosely based on [these](https://github.com/thecatwasnot/passwordsafe/blob/master/features/))


J-\_-L
---
© 2010-2013 Jan Lelis, MIT license
© 2014 Aaron Ciaghi, MIT license (usernames addon)
