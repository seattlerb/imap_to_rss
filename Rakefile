# -*- ruby -*-

require 'rubygems'
require 'hoe'
$:.unshift 'lib'
require 'imap_to_rss'

Hoe.new 'imap_to_rss', IMAPToRSS::VERSION do |itor|
  itor.rubyforge_name = 'seattlerb'
  itor.developer 'Eric Hodel', 'drbrain@example.com'

  itor.extra_deps << ['imap_processor', '~> 1.1']
  itor.extra_deps << ['nokogiri',       '~> 1.2']
  itor.extra_deps << ['tmail',          '~> 1.2']
end

# vim: syntax=Ruby
