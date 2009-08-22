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
      @mail = mail
      @url = nil
      @description = nil

      case mail.from.first
      when 'A2ATransfer@us.hsbc.com' then
        next false unless handle_a2atransfer
      when 'alerts@email.hsbcusa.com' then
        next false unless handle_alert
      when 'HSBC@email.hsbcusa.com' then
        next false unless handle_hsbc
      else
        log "Unknown From: #{mail.from.join ', '}"
        next false
      end

      add_item mail.subject, @description, mail.from, mail.date, @url,
               mail.message_id, 'HSBC'
    end
  end

  def handle_a2atransfer
    @mail.body =~ /^Dear.*?[,:]
                   ([ \t]*\r?\n){2,}
                   (.*?)
                   ([ \t]*\r?\n){2,}
                   Sincerely,/mx

    return false unless $2

    body = $2

    body.gsub!(/[*\r]/, '')
    body.gsub!(/[ \t]*\n/, "\n")
    body = body.split(/\n\n+/).map { |para| "<p>#{para}</p>" }

    @description = body.join "\n\n"
  end

  def handle_alert
    @mail.body =~ /^Dear.*?,
                   ([ \t]*\r?\n){2,}
                   (.*?)
                   ([ \t]*\r?\n){2,}/mx
    return false unless $2

    @description = $2
  end

  def handle_hsbc
    case @mail.body
    when /purchase exceeding/ then
      @mail.body =~ /Description: (.*)/
      purchase = $1.strip
      @mail.body =~ /^Amount: \$\s+([\d.]+)/
      amount = $1

      @description = <<-DESC
<p>Your purchase of #{purchase} was for $#{amount} which exceeds your
notification limit
      DESC
    when /^Dear.*?,
          ([ \t]*\r?\n){2,}
          (.*?)
          ([ \t]*\r?\n){2,}/mx
      @description = $2
    end

    return false unless @description
  end

end

