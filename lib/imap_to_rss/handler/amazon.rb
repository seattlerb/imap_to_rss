require 'imap_to_rss/handler'

class IMAPToRSS::Handler::Amazon < IMAPToRSS::Handler

  def initialize
    @search = 'FROM', 'amazon'
  end

  def handle(uids)
    each_message uids, 'text/plain' do |uid, mail|
      @mail = mail

      case @mail.subject
      when /^Your Order with Amazon.com/ then
        if @mail.body =~ /Your purchase has been divided into/ then
          @mail.body.split(/^Order #\d+/).each do |order|
            add_order order
          end
        else
          add_order @mail.body
        end
      when /has shipped!$/ then
        order_shipped_bang
      when /has shipped/ then
        order_shipped
      when /^Amazon.com - Order Revision \((.*?)\)/ then
        order_revision $1
      when /^Amazon.com - Your Cancellation/ then
        order_cancellation
      when /sent you an Amazon.com Gift Card!$/ then
        gift_card
      when /^Amazon Web Services Billing Statement Available/ then
        aws_bill
      when /^Your savings from Amazon.com/, # ignore
           /^Your Amazon.com Purchase from/ then # dup of regular order email
        next
      else
        log "Unknown Subject: %p" % @mail.subject
        next
      end
    end
  end

  def add_item(subject, description, url)
    super subject, description, @mail.from, @mail.date, url, 'Amazon'
  end

  def add_order(order)
    items = order.scan(/^(\d+) "(.*?)"/)

    order =~ /Order number:\s+([\d-]+)/
    return unless $1
    order_number = $1
    url = order_url order_number

    order =~ /^Total for this Order:\s+(.*)/
    total = $1.strip

    subject = "Amazon order #{order_number}"

    description = "<p>Total: #{total}\n"

    description << order_table(items)

    add_item subject, description, url
  end

  def aws_bill
    @mail.body =~ /^Total: (.*)/
    total = $1

    @mail.body =~ /^(http.*)/

    add_item "Amazon Web Services Bill: #{total}", '', $1
  end

  def gift_card
    url = "https://www.amazon.com/gp/css/account/payment/view-gc-balance.html"
    @mail.body =~ /^Amount: (.*)/
    amount = $1

    @mail.body =~ /^From: (.*)/
    from = $1

    @mail.body =~ /^Gift Message: (.*)/
    message = $1

    @mail.body =~ /^Claim code (.*)/
    claim_code = $1

    subject = "Amazon Gift Card from #{from} - #{amount}!"

    description = "<p><strong>#{from} send you a #{amount} gift card!</strong>\n\n"
    description << "<p>#{message}\n\n"
    description << "<h2>#{claim_code}</h2>\n\n"
    description << "<p><a href=\"#{url}\">Claim your gift card</a>"

    add_item subject, description, url
  end

  def order_cancellation
    @mail.body =~ /order #(.*?) /
    order_number = $1

    items = @mail.body.scan(/(\d?) of (.*)/)

    url = order_url order_number
    subject = "Amazon order cancelation #{order_number}"
    description = "<p>You canceled your order:\n\n"

    description << order_table(items)

    add_item subject, description, url
  end

  def order_shipped
    @mail.body =~ /^(The following items .*?:\r\n.*?)(Shipping Carrier|Item Subtotal)/m
    items = $1.map do |item|
      next unless item =~ /\d+\s(.*?)\$[\d.]+\s+(\d+)/
      [$2, $1.strip]
    end.compact

    carrier = $1.strip         if @mail.body =~ /Shipping Carrier: (.*)/
    date = $1.strip            if @mail.body =~ /Ship Date: (.*)/
    speed = $1.strip           if @mail.body =~ /Shipping Speed: (.*)/
    tracking_number = $1.strip if @mail.body =~ /Carrier Tracking ID: (.*)/

    @mail.body =~ /Your shipping address:\r\n\r\n(.*?)\r\n\r\n/m
    address = $1.split("\n").map { |line| line.strip }.join "<br />\n" if $1

    if tracking_number then
      url = case carrier
            when 'USPS' then
                "http://trkcnfrm1.smi.usps.com/PTSInternetWeb/InterLabelInquiry.do?strOrigTrackNum=#{tracking_number}"
            when 'FedEx' then
                "http://fedex.com/Tracking?tracknumbers=#{tracking_number}"
            else
              log "Unknown carrier: %p" % carrier
              nil
            end
    end

    subject = @mail.subject

    description = order_table items
    if url then
      description << "<p>Via <a href=\"#{url}\">#{carrier}</a>\n\n"
    elsif carrier then
      description << "<p>Via #{carrier} (no tracking number found)\n\n"
    end
    description << "<p>To:<br>\n#{address}" if address

    add_item subject, description, url
  end

  def order_shipped_bang
    @mail.body =~ /this shipment:\r\n\r\n(.*?)\r\n\r\nShip/m
    items = $1.scan(/(\d+) of (.*)/)

    carrier = $1.strip         if @mail.body =~ /Shipped via (.*?)\s/
    tracking_number = $1.strip if @mail.body =~ /Tracking number: (.*?)\s/

    @mail.body =~ /This shipment was sent to:\r\n\r\n(.*?)\r\n\r\n/m
    address = $1.split("\n").map { |line| line.strip }.join "<br />\n" if $1

    if tracking_number then
      url = case carrier
            when 'USPS' then
                "http://trkcnfrm1.smi.usps.com/PTSInternetWeb/InterLabelInquiry.do?strOrigTrackNum=#{tracking_number}"
            when 'FedEx' then
                "http://fedex.com/Tracking?tracknumbers=#{tracking_number}"
            else
              log "Unknown carrier: %p" % carrier
              nil
            end
    end

    subject = @mail.subject

    description = order_table items

    if url then
      description << "<p>Via <a href=\"#{url}\">#{carrier}</a>\n\n"
    elsif carrier then
      description << "<p>Via #{carrier} (no tracking number found)\n\n"
    end
    description << "<p>To:<br>\n#{address}" if address

    add_item subject, description, url
  end

  def order_revision(order_number)
    url = order_url order_number
    subject = "Order Revision (#{order_number})"

    @mail.body =~ /^Dear .*?,\r\n\r\n(.*?)\r\n\r\n/m

    description = "<p>#{$1}"

    add_item subject, description, url
  end

  def order_table(items)
    table = "<table>\n<tr><th>Quantity<th>Description\n"

    items.each do |qty, desc|
      table << "<tr><td>#{qty}<td>#{desc.strip}\n"
    end
    table << "</table>\n\n"

    table
  end

  def order_url(order_number)
    "https://www.amazon.com/gp/css/summary/edit.html?ie=UTF8&orderID=#{order_number}"
  end

end

