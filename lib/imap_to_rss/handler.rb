require 'imap_to_rss'

##
# Base message handler class.  Subclass this to define your own handlers.

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
  # Adds an item to the RSS feed with given parts

  def add_item(title, description, author, pub_date, link = nil, category = nil)
    item = IMAPToRSS::RSSItem.new title, description, author, pub_date, link,
                                  category

    @itor.rss_items << item
  end

  ##
  # Delegates to IMAPToRSS#each_message

  def each_message(*args, &block)
    @itor.each_message(*args, &block)
  end

  def handle(uids)
    raise NotImplementedError, 'write me'
  end

  ##
  # Delegates to IMAPToRSS

  def log(*args)
    @itor.log(*args)
  end

  def setup(imap_to_rss)
    @itor = imap_to_rss
    @imap = imap_to_rss.imap
  end

end

