# -*- ruby -*-

require 'rubygems'
require 'hoe'

Hoe.add_include_dirs "../../imap_processor/dev/lib"

Hoe.spec 'imap_to_rss' do
  developer 'Eric Hodel', 'drbrain@example.com'

  self.rubyforge_name = 'seattlerb'
  self.testlib = :minitest

  extra_deps << ['imap_processor', '~> 1.1']
  extra_deps << ['nokogiri',       '~> 1.2']
  extra_deps << ['tmail',          '~> 1.2']
end

# vim: syntax=Ruby
