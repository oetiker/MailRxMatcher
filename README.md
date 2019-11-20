MailRxMatcher
=========

Version: #VERSION#
Date: #DATE#

mail-rx-match.pl extracts the text content from mail messages
trying its best to undo any encoding and quoting and html entity coding
the spammers are employing to obfuscate mail messages such that
spam checkers do not find keywords. 

`mail-rx-match.pl` is intended to be used in `.procmailrc` scripts like this:

```
 # spam with image
:0 BH
* Content-Type.*jpeg
CATCH=| ./opt/mail2txt/bin/mail-rx-match.pl --charset=utf8 '(Bad|Ugly|Words)'

:0
* ? test "$CATCH" = MATCH
mail/spam
```

It comes complete with a classic "configure - make - install" setup.

Setup
-----
In your app source directory and start building.

```console
./configure --prefix=$HOME/opt/mail-rx-match
make
```

Configure will check if all requirements are met and give
hints on how to fix the situation if something is missing.

Any missing perl modules will be downloaded and built.

Installation
------------

To install the application, just run

```console
make install
```

Enjoy!

Tobias Oetiker <tobi@oetiker.ch>
