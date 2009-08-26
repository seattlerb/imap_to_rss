require 'imap_to_rss/test_case'

class IMAPToRSS::Handler::UPS
  attr_accessor :_mail

  def each_message(a, b)
    yield nil, @_mail
  end
end

class TestIMAPToRSSHandlerUPS < IMAPToRSS::TestCase
  def setup
    super IMAPToRSS::Handler::UPS.new
  end

  def test_handle
    @handler._mail = util_mail :body => <<-BODY
***Do not reply to this e-mail.  UPS and NAME will not rec=
eive your reply.

This message was sent to you at the request of NAME to not=
ify you that the electronic shipment information below has been transmitted=
 to UPS. The physical package(s) may or may not have actually been tendered=
 to UPS for shipment. To verify the actual transit status of your shipment,=
 click on the tracking link below to view the status of your request.


Important Delivery Information
_______________________________________________________________

Scheduled Delivery: 00-XXX-1111

Shipment Detail
_______________________________________________________________
Ship To:

Eric Hodel
1234 Any Street
Any Town
ZZ
00000
US

Number of Packages   1
UPS Service:   GROUND
Weight:   3.0 LBS

Tracking Number:   1AAA22222222222222
Reference Number 1:   3333333
Reference Number 2:   B444444

You can track your shipment by visiting http://wwwapps.ups.com/WebTracking/=
processRequest?HTMLVersion=3D5.0&Requester=3DNES&AgreeToTermsAndConditions=
=3Dyes&loc=3Den_US&tracknum=3D1AAA22222222222222 on the Internet.

_______________________________________________________________
    BODY

    @handler.handle nil

    refute_empty @itor.rss_items
    item = @itor.rss_items.first

    url = 'http://wwwapps.ups.com/WebTracking/processRequest?tracknum=1AAA22222222222222'
    desc = "Package shipped: <a href=\"#{url}\">1AAA22222222222222</a>"

    assert_equal desc,  item.description
    assert_equal url,   item.link
    assert_equal 'UPS', item.category
  end

end
