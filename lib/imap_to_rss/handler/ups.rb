require 'imap_to_rss/handler'

class IMAPToRSS::Handler::UPS < IMAPToRSS::Handler

  def initialize
    @search = 'FROM', 'ups'
  end

  def handle(uids)
    each_message uids, 'text/plain' do |uid, mail|
      mail.body =~ /Tracking Number:\s+(\w+)/

      tracking_number = $1

      url = "http://wwwapps.ups.com/WebTracking/processRequest?tracknum=#{tracking_number}"

      description = %{Package shipped: <a href="#{url}">#{tracking_number}</a>}

      add_item mail.subject, description, mail.from, mail.date, url, 'UPS'
    end
  end

end

