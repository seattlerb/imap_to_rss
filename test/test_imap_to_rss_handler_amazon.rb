require 'imap_to_rss/test_case'

class TestIMAPToRSSHandlerAmazon < IMAPToRSS::TestCase

  def setup
    super IMAPToRSS::Handler::Amazon.new
  end

  def test_add_item
    @handler.mail = util_mail

    @handler.add_item 'toy', 'fun to play with', 'http://example.com/item'

    assert_equal 1, @itor.rss_items.length

    rss_item = @itor.rss_items.first
    assert_equal 'toy',                     rss_item.title
    assert_equal 'fun to play with',        rss_item.description
    assert_equal ['from@example.com'],      rss_item.author
    assert_equal Time.at(0),                rss_item.pub_date
    assert_equal 'http://example.com/item', rss_item.link
    assert_equal nil,                       rss_item.guid
    assert_equal 'Amazon',                  rss_item.category
  end

  def test_add_order
    @handler.mail = util_mail :body => <<-BODY
Thanks for ordering from Amazon.com! Your purchase information appears below.

Want to manage your order online?
If you need to check the status of your order or make changes, please visit our home page at Amazon.com and click on Your Account at the top of any page.
*********************************************************** 
BILLING AND SHIPPING INFORMATION
*********************************************************** 
E-mail Address:	nobody@example.com
Billing Address:
Eric Hodel
100 Any Street
Seattle, WA 98122
United States

Order Grand Total: $51.45

Get the Amazon.com Visa Card, the Amazon.com Business Visa Card or the Amazon.com Student Visa Card instantly and automatically get $30 back after your first purchase. Plus get up to 3% rewards. Click http://www.amazon.com/InstantRewards for more information.

***********************************************************
	ORDER DETAILS
***********************************************************

Please note: Pre-order Price Guarantee covers one or more item(s) in this order. If the Amazon.com price decreases between your order time and the release date, you'll receive the lowest price. See details here http://www.amazon.com/exec/obidos/tg/browse/-/468502

Shipping Details 

(order will arrive in 1 shipment)
***********************************************************
Order number:			000-1111111-2222222
View your Order Summary online: https://www.amazon.com/gp/css/history/view.html
Shipping Method:		FREE Super Saver Shipping
Shipping Preference:		Group my items into as few shipments as possible

Subtotal of Items:             $46.99
Shipping & Handling:            $4.49
Super Saver Discount:          -$4.49
Pre-order Guarantee:           -$0.00
                             ---------
Total before tax:              $46.99
Estimated Tax:                  $4.46
                             ---------
Total for this Order:          $51.45

Shipping To

Eric Hodel
100 Any Street
Seattle, WA 98122
United States

Shipping estimate for these items: September 28, 2009

1 "Katamari Forever"
Video Game; $46.99

Sold by: Amazon.com, LLC

Because of Pre-order Price Guarantee, you might pay less. Learn more at http://www.amazon.com/exec/obidos/tg/browse/-/468502

*********************************************************** 
Our Pre-order Price Guarantee covers one or more item(s) in this order. If the Amazon.com price decreases between the time you place your order and the end of the day of the release date, you'll receive the lowest price.
*********************************************************** 
Need to give a gift? Not sure what to buy?
Amazon.com gift certificates/cards are availablein any dollar amount from $5 to $5,000.
We'll deliver it via e-mail--it's the perfect last-minute gift.
Learn more at http://www.amazon.com/gift-certificates
*********************************************************** 
Got questions? We've got answers. Visit our online Help department, available 24 hours a day: http://www.amazon.com/help 

***********************************************************
Please note: This e-mail message was sent from a notification-only address that cannot accept incoming e-mail. Please do not reply to this message. 
Thanks again for shopping with us.
------------------------------------------------------------- 
Amazon.com
Earth's Biggest Selection
http://www.amazon.com
-------------------------------------------------------------
    BODY

    @handler.add_order @handler.mail.body

    assert_equal 1, @itor.rss_items.length

    rss_item = @itor.rss_items.first
    assert_equal 'Amazon order 000-1111111-2222222', rss_item.title
    description = <<-DESC
<p>Total: $51.45
<table>
<tr><th>Quantity<th>Description
<tr><td>1<td>Katamari Forever
</table>

    DESC
    assert_equal description,          rss_item.description
    assert_equal ['from@example.com'], rss_item.author
    assert_equal Time.at(0),           rss_item.pub_date
    assert_equal 'https://www.amazon.com/gp/css/summary/edit.html?ie=UTF8&orderID=000-1111111-2222222',
                 rss_item.link
    assert_equal nil,                  rss_item.guid
    assert_equal 'Amazon',             rss_item.category
  end

  def test_aws_bill
    @handler.mail = util_mail :body => <<-BODY
Greetings from Amazon Web Services,

This e-mail confirms that your latest billing statement is available on the AWS web site. Your account will be charged the following:

Total: $0.10

Please see the Account Activity area of the AWS web site for detailed account information:

http://example.com/aws/bill

Thank you for your continuing interest in Amazon Web Services.

Sincerely,

Amazon Web Services

This message was produced and distributed by Amazon Web Services LLC, 1200 12th Avenue South, Seattle, Washington 98144-2734
    BODY

    @handler.aws_bill

    assert_equal 1, @itor.rss_items.length

    rss_item = @itor.rss_items.first
    assert_equal 'Amazon Web Services Bill: $0.10', rss_item.title
    assert_equal '',                                rss_item.description
    assert_equal ['from@example.com'],              rss_item.author
    assert_equal Time.at(0),                        rss_item.pub_date
    assert_equal 'http://example.com/aws/bill',     rss_item.link
    assert_equal nil,                               rss_item.guid
    assert_equal 'Amazon',                          rss_item.category
  end

  def test_gift_card
    @handler.mail = util_mail :body => <<-BODY
You've received an Amazon.com gift card! The generous person who gave you this gift is 
listed below.

DON'T DELETE THIS MESSAGE! You'll need the claim code below to place your order.

Happy shopping!


Amazon.com Gift Cards Team
http://www.amazon.com/gc

***********************************************************************

To: Me
Amount: $100.00
From: You
Gift Message: Thanks!

Claim code AAAA-BBBBBB-CCCC
Order DDD-EEEEEEE-FFFFFFF

To begin shopping now:

1. Visit our Web site at http://www.amazon.com

2. Select the items you want; you can add them to your Shopping Cart or use 1-Click ordering.

3. If you're checking out from the Shopping Cart, redeem your gift card by entering the claim code on the order form. 
If you're placing an order with 1-Click: 
Click the "Review or edit your 1-Click orders" link that you'll see after clicking the 
"Buy now with 1-Click" button and enter the code in the Payment section on the next page.

Not ready to use it yet? 

Just add the gift card funds to your account so they'll be there when you're ready! 

1. Go to Your Account. 
2. Click "Apply a gift card to your account" under "Payment Settings". 
3. Sign in with your e-mail address and password. 
4. Enter your claim code and click "Redeem now". Your funds will automatically be applied to your next order.

For more information on using your gift card, visit http://www.amazon.com/help/gc


TERMS AND CONDITIONS:
1.	Redemption.  Gift Cards must be redeemed through the Amazon.com Web site, http://www.amazon.com, toward the purchase of eligible products.  Purchases are deducted from the Gift Card balance.  Any unused balance will be placed in the recipient's Gift Card account when redeemed.  If an order exceeds the amount of the Gift Card, the balance must be paid with a credit card or other available payment method. To redeem or view Gift Card balances, visit "Your Account" on Amazon.com.
2.	Limitations.  
	*	Gift Cards cannot be redeemed for purchases of from some third party sellers (including Eddie Bauer, Newport News, and The Bombay Company), or at Amazon Auctions.  Additional ineligible sellers may be added. Please check the Amazon.com Web site at http://www.amazon.com/gc-legal for the most current list. 
	*	Gift Cards may not be redeemed for the purchase of products through in-store pickup, or at Amazon.co.uk, Amazon.de, Amazon.fr, Amazon.co.jp, Amazon.ca, or any other Web site operated by Amazon.com, its affiliates, or any other person or entity. 
	*	Gift Cards cannot be used to purchase other Gift Cards, such as Amazon.com Gift Cards, Target Gift Cards, or Borders Gift Cards. 
	*	Gift Cards cannot be reloaded, resold, transferred for value, redeemed for cash or applied to any other account, except to the extent required by law.  Unused Gift Card balances in an Amazon account may not be transferred.
3.	Our Policies.  Gift Cards and their use on the Amazon.com Web site are subject to Amazon.com's general Conditions of Use and Privacy Notice.  Amazon.com may provide Gift Card purchasers with information about the redemption status of Gift Cards. 
4.	Risk of Loss.  The risk of loss and title for Gift Cards pass to the purchaser upon our electronic transmission to the recipient or delivery to the carrier, whichever is applicable.  We are not responsible for lost or stolen Gift Cards. If you have any questions, please see www.amazon.com/gc.
5.	Fraud. Amazon.com will have the right to close customer accounts and request alternative forms of payment if a fraudulently obtained Gift Card is either redeemed through the Amazon.com Web site or is redeemed and used to make purchases on the Amazon.com Web site. 
6.	Limitation of Liability.  ACI GIFT CARDS, INC. ("ACI") AND ITS AFFILIATES MAKE NO WARRANTIES, EXPRESS OR IMPLIED, WITH RESPECT TO GIFT CARDS, INCLUDING WITHOUT LIMITATION, ANY EXPRESS OR IMPLIED WARRANTY OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. IN THE EVENT A GIFT CARD CODE IS NON-FUNCTIONAL, YOUR SOLE REMEDY, AND OUR SOLE LIABILITY, SHALL BE THE REPLACEMENT OF SUCH GIFT CARD. CERTAIN STATE LAWS DO NOT ALLOW LIMITATIONS ON IMPLIED WARRANTIES OR THE EXCLUSION OR LIMITATION OF CERTAIN DAMAGES. IF THESE LAWS APPLY TO YOU, SOME OR ALL OF THE ABOVE DISCLAIMERS, EXCLUSIONS, OR LIMITATIONS MAY NOT APPLY TO YOU, AND YOU MIGHT HAVE ADDITIONAL RIGHTS. 
7.  Disputes. Any dispute relating in any way to Amazon.com Gift Cards in which the aggregate total claim for relief sought on behalf of one or more parties exceeds $7,500 shall be adjudicated in any state or federal court in King County, Washington, and you consent to exclusive jurisdiction and venue in such courts.
8.	General Terms.  Amazon.com Gift Cards are issued by ACI, a Washington corporation.  By visiting Amazon.com, you agree that the laws of the State of Washington, without regard to principles of conflict of laws, will govern these Gift Card terms and conditions.  ACI reserves the right to change these terms and conditions from time to time in its discretion. All terms and conditions are applicable to the extent permitted by law. 


***********************************************************************
    BODY

    @handler.gift_card

    assert_equal 1, @itor.rss_items.length

    rss_item = @itor.rss_items.first
    assert_equal 'Amazon Gift Card from You - $100.00!', rss_item.title
    description = <<-DESC.strip
<p><strong>You sent you a $100.00 gift card!</strong>

<p>Thanks!

<h2>AAAA-BBBBBB-CCCC</h2>

<p><a href="https://www.amazon.com/gp/css/account/payment/view-gc-balance.html">Claim your gift card</a>
    DESC
    assert_equal description,          rss_item.description
    assert_equal ['from@example.com'], rss_item.author
    assert_equal Time.at(0),           rss_item.pub_date
    assert_equal 'https://www.amazon.com/gp/css/account/payment/view-gc-balance.html',
                 rss_item.link
    assert_equal nil,                  rss_item.guid
    assert_equal 'Amazon',             rss_item.category
  end

  def test_order_cancelation
    @handler.mail = util_mail :body => <<-BODY
Dear Eric Hodel,

Your order has been successfully canceled. For your reference, here's a 
summary of your order:

You just canceled order #000-1111111-2222222 placed on MM DD, YYYY.

Status: CANCELED

_____________________________________________________________________

1 of A. [CD-ROM]
1 of B [CD-ROM]
1 of C [CD-ROM]
1 of D

_____________________________________________________________________

Because you only pay for items when we ship them to you, you won't be 
charged for any items that you cancel.

Thank you for visiting Amazon.com!

---------------------------------------------------------------------
Amazon.com
Earth's Biggest Selection
http://www.amazon.com
---------------------------------------------------------------------
    BODY

    @handler.order_cancellation

    assert_equal 1, @itor.rss_items.length

    rss_item = @itor.rss_items.first
    assert_equal 'Amazon order cancellation 000-1111111-2222222', rss_item.title
    description = <<-DESC
<p>You cancelled your order:

<table>
<tr><th>Quantity<th>Description
<tr><td><td>your order:
<tr><td>1<td>A. [CD-ROM]
<tr><td>1<td>B [CD-ROM]
<tr><td>1<td>C [CD-ROM]
<tr><td>1<td>D
</table>

    DESC
    assert_equal description,          rss_item.description
    assert_equal ['from@example.com'], rss_item.author
    assert_equal Time.at(0),           rss_item.pub_date
    assert_equal 'https://www.amazon.com/gp/css/summary/edit.html?ie=UTF8&orderID=000-1111111-2222222', rss_item.link
    assert_equal nil,                  rss_item.guid
    assert_equal 'Amazon',             rss_item.category
  end

  def test_order_shipped
    @handler.mail = util_mail :subject => 'Your Amazon.com order has shipped (#000-1111111-2222222)',
                              :body => <<-BODY
Greetings from Amazon.com.

We thought you'd like to know that we shipped your items, and that this 
completes your order.  Your order is being shipped and cannot be changed 
by you or by our customer service department. 

You can track the status of this order, and all your orders, online by 
visiting Your Account at http://www.amazon.com/gp/css/history/view.html

There you can:
       * Track your shipment
       * View the status of unshipped items 
       * Cancel unshipped items 
       * Return items 
       * And do much more

The following items have been shipped to you by Amazon.com: 
--------------------------------------------------------------------
Qty                           Item    Price         Shipped Subtotal

---------------------------------------------------------------------

Amazon.com items (Sold by Amazon.com, LLC):

  1  2001 - A Space Odyssey [Bl...   $17.99               1   $17.99

Shipped via USPS

Tracking number: 9102999999999999999999

---------------------------------------------------------------------
                          Item Subtotal:     $17.99
                 Shipping  and handling:      $2.98

                              Sales Tax:      $1.99

                                  Total:     $22.96

                     Paid by Mastercard:     $22.96

   --------------------------------------------------------------------

This shipment was sent to:

   Eric Hodel
   101 Any Street
   Seattle, WA 98122
   United States

via USPS (estimated delivery date: July  1,2009).

For your reference, the number you can use to track your package is 
9102999999999999999999.Visit http://www.amazon.com/wheres-my-stuff to 
track your shipment.Please note that tracking information may not be 
available immediately.

If you need to print an invoice for this order, visit Your Account 
(www.amazon.com/your-account) and click to view open and recently shipped 
orders. Find the order in the list and click the "View order" button. 
You'll find a button to print an invoice on the next page.

If you ever need to return an order, visit our Online Returns Center: 
www.amazon.com/returns

If you've explored the links on the Your Account page but still need
assistance with your order, you'll find links to e-mail or call
Amazon.com Customer Service
in our Help department at http://www.amazon.com/help/

---------------------------------------------------------------------
Please be aware that items in this order may be subject to California's
Electronic Waste Recycling Act. If any items in this order are subject
to that Act, the seller of that item has elected to pay any fees due
on your behalf.
--------------------------------------------------------------------- 
Please note: This e-mail was sent from a notification-only address
that cannot accept incoming e-mail. Please do not reply to this message.

Thank you for shopping with us.

---------------------------------------------------------------------
Amazon.com... and you're done!
http://www.amazon.com/
---------------------------------------------------------------------

    BODY

    @handler.order_shipped

    assert_equal 1, @itor.rss_items.length

    rss_item = @itor.rss_items.first
    assert_equal 'Your Amazon.com order has shipped (#000-1111111-2222222)',
                 rss_item.title
    description = <<-DESC.strip
<table>
<tr><th>Quantity<th>Description
<tr><td>1<td>2001 - A Space Odyssey [Bl...
</table>

<p>Via <a href=\"http://trkcnfrm1.smi.usps.com/PTSInternetWeb/InterLabelInquiry.do?strOrigTrackNum=9102999999999999999999\">USPS</a>

<p>To:<br>
Eric Hodel<br />
101 Any Street<br />
Seattle, WA 98122<br />
United States
    DESC
    assert_equal description,          rss_item.description
    assert_equal ['from@example.com'], rss_item.author
    assert_equal Time.at(0),           rss_item.pub_date
    assert_equal 'http://trkcnfrm1.smi.usps.com/PTSInternetWeb/InterLabelInquiry.do?strOrigTrackNum=9102999999999999999999',
                 rss_item.link
    assert_equal nil,                  rss_item.guid
    assert_equal 'Amazon',             rss_item.category
  end

  def test_order_shipped_2
    @handler.mail = util_mail :subject => 'Your Amazon.com order has shipped (#000-1111111-2222222)',
                              :body => <<-BODY
Greetings from Amazon.com.

We thought you'd like to know that we shipped your items, and that this 
completes your order.  Your order is being shipped and cannot be changed 
by you or by our customer service department. 

You can track the status of this order, and all your orders, online by 
visiting Your Account at http://www.amazon.com/gp/css/history/view.html

There you can:
        * Track your shipment
        * View the status of unshipped items 
        * Cancel unshipped items 
        * Return items 
        * And do much more

The following items have been shipped to you by Amazon.com: 
--------------------------------------------------------------------
 Qty                           Item    Price         Shipped Subtotal

---------------------------------------------------------------------

Amazon.com items (Sold by Amazon.com, LLC):

   1  Fujitsu ScanSnap S1500M In...  $404.99               1  $404.99

Shipped via UPS

Tracking number: 1A222B333333333333

---------------------------------------------------------------------
                           Item Subtotal:    $404.99
                  Shipping  and handling:     $11.48

                    Super Saver Discount:    $-11.48

                          Reward Applied:      $0.00

                               Sales Tax:     $38.46

                                   Total:    $443.45

                      Paid by Mastercard:    $443.45

    --------------------------------------------------------------------

This shipment was sent to:

    Eric Hodel
    101 Any Street
    Seattle, WA 98122
    United States

via UPS (estimated delivery date: September  3, 2009).

For your reference, the number you can use to track your package is 
1A222B333333333333.Visit http://www.amazon.com/wheres-my-stuff to track 
your shipment.Please note that tracking information may not be available 
immediately.
        
Please note that a signature may be required for the delivery of any
package where the value of the contents is greater than $400.  If no
one will be available to sign for this package, you may wish to make
alternate delivery arrangements with the carrier.

If you need to print an invoice for this order, visit Your Account 
(www.amazon.com/your-account) and click to view open and recently shipped 
orders. Find the order in the list and click the "View order" button. 
You'll find a button to print an invoice on the next page.

If you ever need to return an order, visit our Online Returns Center: 
www.amazon.com/returns

If you've explored the links on the Your Account page but still need
assistance with your order, you'll find links to e-mail or call
Amazon.com Customer Service
in our Help department at http://www.amazon.com/help/

---------------------------------------------------------------------
Please be aware that items in this order may be subject to California's
Electronic Waste Recycling Act. If any items in this order are subject
to that Act, the seller of that item has elected to pay any fees due
on your behalf.
--------------------------------------------------------------------- 
Please note: This e-mail was sent from a notification-only address
that cannot accept incoming e-mail. Please do not reply to this message.

Thank you for shopping with us.

---------------------------------------------------------------------
Amazon.com... and you're done!
http://www.amazon.com/
---------------------------------------------------------------------


    BODY

    @handler.order_shipped

    assert_equal 1, @itor.rss_items.length

    rss_item = @itor.rss_items.first
    assert_equal 'Your Amazon.com order has shipped (#000-1111111-2222222)',
                 rss_item.title
    description = <<-DESC.strip
<table>
<tr><th>Quantity<th>Description
<tr><td>1<td>Fujitsu ScanSnap S1500M In...
</table>

<p>Via <a href=\"http://wwwapps.ups.com/WebTracking/processInputRequest?InquiryNumber1=1A222B333333333333\">UPS</a>

<p>To:<br>
Eric Hodel<br />
101 Any Street<br />
Seattle, WA 98122<br />
United States
    DESC
    assert_equal description,          rss_item.description
    assert_equal ['from@example.com'], rss_item.author
    assert_equal Time.at(0),           rss_item.pub_date
    assert_equal 'http://wwwapps.ups.com/WebTracking/processInputRequest?InquiryNumber1=1A222B333333333333',
                 rss_item.link
    assert_equal nil,                  rss_item.guid
    assert_equal 'Amazon',             rss_item.category
  end

  def test_order_shipped_bang
    @handler.mail = util_mail :subject => 'Your Amazon.com order 000-1111111-2222222 has shipped!',
                              :body => <<-BODY

Dear drbrain@segment7.net,

Today Smart Home Systems, Inc. shipped item(s) in your order, placed on 
June 20,2009.

==================================================
SHIPPING DETAILS
==================================================

The following items were sold by and shipped from Smart Home Systems, Inc. 
in package 1 of this shipment:

2 of X10 PRO Wall Switch White

Shipping Carrier: USPS

Ship Date: June 22,2009
Shipping Speed: Standard
Carrier Tracking ID: 9101999999999999999999
	
Your shipping address:

   Eric Hodel
   101 Any Street
   Seattle, WA 98122
   United States

If you have additional items in your order, you will receive an e-mail 
when those items have shipped.

QUESTIONS? 

If you have questions about this order, including the status of your 
shipment, you can either visit http://www.amazon.com/wheres-my-stuff or 
e-mail amazonorders@smarthomeusa.com to get in touch directly with Smart 
Home Systems, Inc..

**************************************************
Safe Shopping Tips
Amazon.com works hard to protect our customers. For your safety, when 
ordering items advertised by sellers other than Amazon.com: 

* Always place your orders directly through the Amazon.com shopping cart 
using Amazon Payments. Never send money directly to sellers through wire 
transfers or checks; we do not guarantee such transactions. 

* Beware of e-mails that request direct payments, request payment to 
international locations, or ask for personal information. Amazon.com will 
never e-mail you to pay for Marketplace transactions outside our shopping 
cart, or ask you to confirm personal information such as a credit card 
number or password via e-mail. If a particular e-mail looks suspicious or 
unusual, please contact us directly. 

Reporting suspicious activity at 
http://www.amazon.com/gp/help/reports/contact-us will help us enhance 
marketplace safety and serve you better in the future. 

For more safe-shopping tips, read about Safe Online Transactions at 
http://www.amazon.com/safe-secure.
************************************************** 

==================================================
Order Details
==================================================

Date:                June 20,2009

Amazon Order #:      000-1111111-2222222

Smart Home Systems, Inc. Order #: 33333

2 of X10 PRO Wall Switch White, $11.95*

*above item(s) sold by and shipped from Smart Home Systems, Inc. 
---------------------------------------------------------------------
              Item Subtotal:  $23.90
        Shipping & Handling:  $8.95 

                       Total:  $32.85

               Paid by Mastercard:  $32.85 

  ---------------------------------------------------------------------

Thanks for shopping at Amazon.com.

http://www.amazon.com/
Earth's Biggest Selection
Find, Discover & Buy Virtually Anything

    BODY

    @handler.order_shipped_bang

    assert_equal 1, @itor.rss_items.length

    rss_item = @itor.rss_items.first
    assert_equal 'Your Amazon.com order 000-1111111-2222222 has shipped!',
                 rss_item.title
    description = <<-DESC
<table>
<tr><th>Quantity<th>Description
<tr><td>2<td>X10 PRO Wall Switch White
</table>

    DESC
    assert_equal description,          rss_item.description
    assert_equal ['from@example.com'], rss_item.author
    assert_equal Time.at(0),           rss_item.pub_date
    assert_equal nil,                  rss_item.link
    assert_equal nil,                  rss_item.guid
    assert_equal 'Amazon',             rss_item.category
  end

  def test_order_revision
    @handler.mail = util_mail :body => <<-BODY
Dear Eric Hodel,

Thanks for approving the delay in your order #000-1111111-2222222.

We appreciate your patience, and we apologize for any inconvenience. Please note that we don't charge you for an item until we're ready to ship it. On the day we ship your order, we'll send you an e-mail message confirming its contents and the shipping method.

Thank you for visiting Amazon.com!

---------------------------------------------------------------------
Amazon.com
Earth's Biggest Selection
http://www.amazon.com
---------------------------------------------------------------------
    BODY

    @handler.order_revision '000-1111111-2222222'

    assert_equal 1, @itor.rss_items.length

    rss_item = @itor.rss_items.first
    assert_equal 'Order Revision (000-1111111-2222222)', rss_item.title
    assert_equal '<p>Thanks for approving the delay in your order #000-1111111-2222222.',
                 rss_item.description
    assert_equal ['from@example.com'],      rss_item.author
    assert_equal Time.at(0),                rss_item.pub_date
    assert_equal 'https://www.amazon.com/gp/css/summary/edit.html?ie=UTF8&orderID=000-1111111-2222222',
                 rss_item.link
    assert_equal nil,                       rss_item.guid
    assert_equal 'Amazon',                  rss_item.category
  end

  def test_order_table
    items = [
      [2, "rubber chickens\n"],
      [5, 'whoopie cushions']
    ]

    expected = <<-TABLE
<table>
<tr><th>Quantity<th>Description
<tr><td>2<td>rubber chickens
<tr><td>5<td>whoopie cushions
</table>

    TABLE

    assert_equal expected, @handler.order_table(items)
  end

  def test_order_url
    assert_equal "https://www.amazon.com/gp/css/summary/edit.html?ie=UTF8&orderID=000-1111111-2222222",
                 @handler.order_url('000-1111111-2222222')
  end

end

