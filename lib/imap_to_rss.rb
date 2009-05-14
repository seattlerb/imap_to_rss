require 'rubygems'
require 'imap_processor'
require 'tmail'
require 'nokogiri'

##
# IMAPToRSS takes messages from your mailboxes, runs them through handlers,
# then turns them into an RSS feed.  Handlers can be added via a plugin system
# so long as they subclass IMAPToRSS::Handler and live in the
# <tt>imap_to_rss/handler/</tt> directory.

class IMAPToRSS < IMAPProcessor

  ##
  # The version of IMAPToRSS you are using

  VERSION = '1.0'

  ##
  # A Struct representing an RSS item for the RSS feed.  Contains fields
  # +title+, +description+, +author+, +pub_date+, +link+, +category+.

  RSSItem = Struct.new :title, :description, :author, :pub_date,
                       :link, :category

  ##
  # All added RSS items

  attr_reader :rss_items

  ##
  # Processes command-line options

  def self.process_args(args)
    add_move

    super __FILE__, args do |opts, options|
      handlers = IMAPToRSS::Handler.handlers.map do |handler|
        handler.name.split('::').last
      end

      opts.separator ''
      opts.separator "Handlers: #{handlers.join ', '}"
      opts.separator ''

      opts.on(      "--handler=HANDLER", handlers,
              "Handler to run",
              "Default: all handlers") do |handler|
        options[:Handler] = handler
      end
    end
  end

  ##
  # Creates a new IMAPToRSS and connects to the selected server.

  def initialize(options)
    super

    @handlers = []
    @rss_items = []

    connection = connect options[:Host], options[:Port], options[:SSL],
                         options[:Username], options[:Password], options[:Auth]

    @imap = connection.imap
  end

  ##
  # Builds an RSS feed from rss_items

  def build_rss
    log 'Building RSS feed'
    rss = Nokogiri::XML::Builder.new

    rss_items = @rss_items.sort_by { |rss_item| rss_item.pub_date }
    host = options[:Host]

    copyover = []

    if File.exist? 'imap_to_rss.rss' then
      doc = nil

      open 'imap_to_rss.rss', 'rb' do |io| doc = Nokogiri::XML io end

      copyover_count = 50 - rss_items.length

      if copyover_count > 0 then
        items = doc.xpath('//rss/channel/item')

        index = [copyover_count, items.length].min

        copyover = items.to_a[-index..-1]
      end
    end

    rss.rss :version => '2.0' do
      rss.channel do
        rss.title 'IMAP to RSS'
        rss.link "imap://#{host}"
        rss.description "An RSS feed built from your IMAP server"
        rss.generator "imap_to_rss version #{IMAPToRSS::VERSION}"
        rss.docs 'http://cyber.law.harvard.edu/rss/rss.html'

        copyover.each do |item|
          rss.send :insert, item
        end

        rss_items.each do |item|
          rss.item do
            rss.title item.title
            rss.description item.description
            rss.author item.author
            rss.pubDate item.pub_date
            rss.link item.link if item.link
            rss.category item.category if item.category
          end
        end
      end
    end

    open 'imap_to_rss.rss', 'w' do |io|
      io.write rss.to_xml
    end

    log 'Saved RSS feed'
  end

  ##
  # Processes mailboxes with each handler then writes out the RSS file.

  def run
    handlers = IMAPToRSS::Handler.handlers

    handlers.delete_if do |handler|
      handler.name.split('::').last != options[:Handler]
    end if options[:Handler]

    handlers = handlers.map do |handler|
      handler = handler.new
      handler.setup self
      handler
    end

    dest_mailbox = options[:MoveTo]

    @boxes.each do |mailbox|
      @imap.select mailbox
      log "Selected mailbox #{mailbox}"

      handlers.each do |handler|
        log "Running handler #{handler.search.join ' '}"
        messages = @imap.search [
          'NOT', 'DELETED',
          'NOT', 'KEYWORD', 'IMAP_TO_RSS',
          *handler.search
        ]

        next if messages.empty?

        handled = handler.handle messages

        @imap.store handled, '+FLAGS', %w[IMAP_TO_RSS]

        if dest_mailbox then
          @imap.copy handled, dest_mailbox
          @imap.store handled, '+FLAGS', [:Deleted]
          @imap.expunge
        end
      end

      build_rss
    end
  end

end

plugins = Gem.find_files 'imap_to_rss/handler/*'

plugins.each do |plugin|
  # strip path info to always require latest
  require plugin.sub(/.*(imap_to_rss.handler.*)\.[^.]+$/, '\1')
end

