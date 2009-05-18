require 'imap_to_rss/handler'

##
# Handles messages from HSBC savings and HSBC credit cards

class IMAPToRSS::Handler::HSBC < IMAPToRSS::Handler

  ##
  # Selects messages with hsbc in the From header

  def initialize
    @search = 'FROM', 'hsbc'
  end

  ##
  # Turns +uids+ into RSS items for bank-to-bank transfers and general
  # announcements like CC payments due or interest rate changes.

  def handle(uids)
    each_message uids, 'text/plain' do |uid, mail|
      url = nil
      description = nil

      case mail.from.first
      when 'HSBC@email.hsbcusa.com' then
        mail.body =~ /^Dear.*?,
                      ([ \t]*\r?\n){2,}
                      (.*?)
                      ([ \t]*\r?\n){2,}/mx
        next false unless $2

        description = $2
      when 'A2ATransfer@us.hsbc.com' then
        mail.body =~ /^Dear.*?[,:]
                      ([ \t]*\r?\n){2,}
                      (.*?)
                      ([ \t]*\r?\n){2,}
                      Sincerely,/mx
        next false unless $2

        body = $2

        body.gsub!(/[*\r]/, '')
        body.gsub!(/[ \t]*\n/, "\n")
        body = body.split(/\n\n+/).map { |para| "<p>#{para}</p>" }

        description = body.join "\n\n"
      when 'alerts@email.hsbcusa.com' then
        mail.body =~ /^(http:.*)/
        next false unless $1

        url = $1
      else
        log "Unknown From: #{mail.from.join ', '}"
        next false
      end

      add_item mail.subject, description, mail.from, mail.date, url,
               mail.message_id, 'HSBC'
    end
  end

end

