require 'imap_to_rss/handler'

class IMAPToRSS::Handler::HSBC < IMAPToRSS::Handler

  def initialize
    @search = 'FROM', 'hsbc'
  end

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

        next unless $2

        description = $2
      when 'A2ATransfer@us.hsbc.com' then
        mail.body =~ /^Dear.*?[,:]
                      ([ \t]*\r?\n){2,}
                      (.*?)
                      ([ \t]*\r?\n){2,}
                      Sincerely,/mx

        body = $2
        body.gsub!(/[*\r]/, '')
        body.gsub!(/[ \t]*\n/, "\n")
        body = body.split(/\n\n+/).map { |para| "<p>#{para}</p>" }

        body.join "\n\n"
      when 'alerts@email.hsbcusa.com' then
        mail.body =~ /^(http:.*)/

        url = $1
      else
        log "Unknown From: #{mail.from.join ', '}"
        next
      end

      add_item mail.subject, description, mail.from, mail.date, url, 'HSBC'
    end
  end

end

