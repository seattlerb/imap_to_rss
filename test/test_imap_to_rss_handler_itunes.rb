require 'imap_to_rss/test_case'

class IMAPToRSS::Handler::Itunes
  attr_accessor :_mail

  def each_message(a, b)
    yield nil, @_mail
  end
end

class TestIMAPToRSSHandlerItunes < IMAPToRSS::TestCase

  def setup
    super IMAPToRSS::Handler::Itunes.new
  end

  def test_handle
    @handler._mail = util_mail :body => <<-BODY
Apple Receipt
-----------------------------------------------------------


Billed to:
nobody@example.com
Eric Hodel
123 Any Street


Any Town, ZZ 00000



       Order Number: A1BB22CCCC    
       Receipt Date: 01/02/03
        Order Total: $2.18     
          Billed To: MasterCard .... 0000






Item Number     Description                                              Unit Price
-----------------------------------------------------------------------------------
1               Ragdoll Blaster - A Physics Puzzler, v1.1, Seller:            $1.99

-----------------------------------------------------------------------------------
                                                          Subtotal:          $1.99

                                                               Tax:          $0.19
-----------------------------------------------------------------------------------
                                                 Credit Card Total:          $2.18
-----------------------------------------------------------------------------------
                                                       Order Total:          $2.18


Please retain for your records.
Please See Below For Terms And Conditions Pertaining To This Order.


Apple Inc.
You can find the iTunes Store Terms of Sale and Sales Policies by launching your iTunes application and clicking on http://www.apple.com/legal/itunes/us/sales.html



Answers to frequently asked questions regarding the iTunes Store can be found at
http://www.apple.com/support/itunes/store/



Account Information: https://phobos.apple.com/WebObjects/MZFinance.woa/wa/accountSummary
Purchase History: https://phobos.apple.com/WebObjects/MZFinance.woa/wa/purchaseHistory

Apple respects your privacy.
Information regarding your personal information can be viewed at
http://www.apple.com/legal/privacy/

Copyright (C) 2008 Apple Inc. All rights reserved
http://www.apple.com/legal/
    BODY

    @handler.handle nil

    refute_empty @itor.rss_items
    item = @itor.rss_items.first

    expected = <<-DESCRIPTION.strip
<table>
<tr><th>Item<th>Price
<tr><td>Ragdoll Blaster - A Physics Puzzler, v1.1, Seller:<td>$1.99
</table>
<p>Total: $2.18
    DESCRIPTION

    assert_equal 'iTunes Receipt #A1BB22CCCC, $2.18', item.title
    assert_equal expected, item.description
    assert_equal 'https://phobos.apple.com/WebObjects/MZFinance.woa/wa/purchaseHistory',
                 item.link
    assert_equal 'iTunes', item.category

  end

end

