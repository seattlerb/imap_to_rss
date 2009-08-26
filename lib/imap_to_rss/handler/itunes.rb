require 'imap_to_rss/handler'

##
# Processes iTunes receipts

class IMAPToRSS::Handler::Itunes < IMAPToRSS::Handler

  def initialize
    @search = 'FROM', 'itunes'
  end

  def handle(uids)
    each_message uids, 'text/plain' do |uid, mail|
      body = ''
      mail.body =~ /Order Number: ([^\s]*)/
      order_number = $1

      next false unless order_number

      mail.body =~ /Order Total: (\$[\d.]+)/
      total = $1

      mail.body =~ /Purchase History:.*?(https:.*?)\r/m
      url = $1

      mail.body =~ /^Item\sNumber.*?
                    (^-+\r\n)
                    (.*?)
                    \1/mx

      body << "<table>\n<tr><th>Item<th>Price\n"

      $2.scan(/^([^\s]+)\s+(.*?)\s+(Free|\$[\d.]+)/) do |item, name, price|
        body << "<tr><td>#{name}<td>#{price}\n"
      end

      body << "</table>\n"

      body << "<p>Total: #{total}"

      subject = "iTunes Receipt ##{order_number}, #{total}"

      add_item subject, body, mail.from, mail.date, url,
               mail.message_id, 'iTunes'
    end
  end

end

