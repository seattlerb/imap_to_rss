require 'minitest/autorun'
require 'imap_to_rss'

# :stopdoc:
class IMAPToRSS
  def connect(*args)
    o = Object.new
    def o.imap() end
    o
  end
end

class IMAPToRSS::Handler
  attr_accessor :mail
end
# :startdoc:

##
# Test case for IMAPToRSS handlers

class IMAPToRSS::TestCase < MiniTest::Unit::TestCase

  ##
  # Sets this test case up with +handler+.  Provides instance variables
  # <tt>@itor</tt> and <tt>@handler</tt>

  def setup(handler)
    @itor = IMAPToRSS.new
    @handler = handler
    @handler.setup @itor
  end

  ##
  # Returns a new TMail::Mail from +options+.  Defaults are:
  #
  # from:: from@example.com
  # date:: Time.at 0
  # to:: to@example.com
  # subject:: subject for this mail
  # body:: Hi! I'm a body!
  #
  # The mail body will be normalized to \r\n line breaks.

  def util_mail(options = {})
    options = {
      :from => 'from@example.com',
      :date => Time.at(0),
      :to => 'to@example.com',
      :subject => 'subject for this mail',
      :body => 'Hi! I\'m a body!'
    }.merge options

    body = options[:body].split(/\r?\n/).join "\r\n"

    TMail::Mail.parse <<-MAIL
From: #{options[:from]}\r
Date: #{options[:date].rfc2822}\r
To: #{options[:to]}\r
Subject: #{options[:subject]}\r
\r
#{body}
    MAIL
  end

end

