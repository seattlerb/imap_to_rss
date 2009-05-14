= imap_to_rss

* http://seattlerb.rubyforge.org/imap_to_rss

== DESCRIPTION:

IMAPToRSS turns messages on an IMAP server into RSS entries when the match a
handler.  Included handlers work for email from Amazon, HSBC and UPS.
IMAPToRSS automatically loads handlers for any other mail.

== SYNOPSIS:

  $ imap_to_rss --boxes INBOX --move _Money
  [...]
  $ open imap_to_rss.rss

See IMAPToRSS::Handler for instructions on writing a handler.

== REQUIREMENTS:

* An IMAP server
* imap_processor
* Email matching one of the handlers

== INSTALL:

* gem install imap_to_rss
* add imap_to_rss to your crontab

== LICENSE:

(The MIT License)

Copyright (c) 2009 Eric Hodel

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
