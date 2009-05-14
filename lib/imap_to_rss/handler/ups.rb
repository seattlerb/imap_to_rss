require 'imap_to_rss/handler'

##
# Turns messages from UPS into links to the tracking page

class IMAPToRSS::Handler::UPS < IMAPToRSS::Handler

  ##
  # Selects messages with ups in the From header

  def initialize
    @search = 'FROM', 'ups'
  end

  ##
  # Scans +uids+ for UPS tracking numbers and turns them into RSS items

  def handle(uids)
    each_message uids, 'text/plain' do |uid, mail|
      mail.body =~ /Tracking Number:\s+(\w+)/

      tracking_number = $1

      url = "http://wwwapps.ups.com/WebTracking/processRequest?tracknum=#{tracking_number}"

      description = %{Package shipped: <a href="#{url}">#{tracking_number}</a>}

      add_item mail.subject, description, mail.from, mail.date, url,
               mail.message_id, 'UPS'
    end
  end

end

