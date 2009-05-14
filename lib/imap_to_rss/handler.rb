require 'imap_to_rss'
require 'time'

##
# Base message handler class.  Subclass this to define your own handlers, and
# override the #initialize and #handle methods.
#
# To have the handler automatically be picked up by IMAPToRSS, place it in the
# <tt>imap_to_rss/handler/</tt> directory.

class IMAPToRSS::Handler

  ##
  # IMAP SEARCH command keywords to search

  attr_accessor :search

  @handlers = []

  ##
  # Collect handler subclasses

  def self.inherited(subclass)
    @handlers << subclass
  end

  ##
  # List of found handlers

  def self.handlers
    @handlers
  end

  ##
  # :method: initialize
  #
  # Override and set <tt>@search</tt> to IMAP search terms for the messages
  # you're interested in.  (Usually something simple like 'FROM', 'amazon' is
  # enough.)  Deleted messages and previously handled messages will be
  # automatically ignored.
  #
  # You can tell imap_to_rss to re-scan messages by clearing the IMAP_TO_RSS
  # keyword with imap_keywords:
  #
  #   imap_keywords --no-list --keywords IMAP_TO_RSS --delete

  ##
  # Adds an item to the RSS feed with given parts

  def add_item(title, description, author, pub_date, link = nil, guid = nil,
               category = nil)
    pub_date = case pub_date
               when Time then
                 pub_date
               when Date, DateTime then
                 Time.parse pub_date.to_s
               else
                 Time.parse pub_date
               end

    item = IMAPToRSS::RSSItem.new title, description, author, pub_date, link,
                                  guid, category

    @itor.rss_items << item
  end

  ##
  # Delegates to IMAPToRSS#each_message

  def each_message(*args, &block)
    @itor.each_message(*args, &block)
  end

  ##
  # Guts of the handler, implement this yourself.  It should call #add_item
  # for each message found.
  #
  # See IMAPToRSS::Handler::UPS for a simple handler,
  # IMAPToRSS::Handler::Amazon for a complex one.

  def handle(uids)
    raise NotImplementedError, 'write me'
  end

  ##
  # Delegates to IMAPToRSS

  def log(*args)
    @itor.log(*args)
  end

  ##
  # Sets up delegators to IMAPToRSS

  def setup(imap_to_rss)
    @itor = imap_to_rss
    @imap = imap_to_rss.imap
  end

end

