require 'imap_to_rss/test_case'

class IMAPToRSS::Handler::HSBC
  attr_reader :description
  attr_reader :url
end

class TestIMAPToRSSHandlerHSBC < IMAPToRSS::TestCase

  def setup
    super IMAPToRSS::Handler::HSBC.new
  end

  def test_handle_a2atransfer
    @handler.mail = util_mail :body => <<-BODY
Dear ERIC,

The funds transfer referenced below has completed.

*******************************************************************
Item #:   00000000

*******************************************************************
 
As of, August 13, 2009, the funds have been credited to the destination account and deducted from the account from which you requested the funds be transfered. 

You may always review this transfer request on the Consolidated History page.

Sincerely,

Jean Carrow
Vice President,
Customer Relationship Center

http://www.us.hsbc.com

Please do not reply to this e-mail as your reply will go to an unmonitored mailbox.  If you have any questions, you may send a secure BankMail from Internet Banking or call our Customer Relationship Center at 1-800-975-HSBC (1-800-975-4722).

This E-mail is confidential. It may also be legally privileged. If you are not the addressee you may not copy, forward, disclose or use any part of it.  If you have received this message in error, please delete it and all copies from your system and notify the sender immediately by return E-mail.  Internet communications cannot be guaranteed to be timely, secure, error or virus-free. The sender does not accept liability for any errors or omissions.


Email ID: YY111

    BODY

    @handler.handle_a2atransfer

    expected = <<-EXPECTED.strip
<p>The funds transfer referenced below has completed.</p>

<p>Item #:   00000000</p>

<p>As of, August 13, 2009, the funds have been credited to the destination account and deducted from the account from which you requested the funds be transfered.</p>

<p>You may always review this transfer request on the Consolidated History page.</p>
    EXPECTED

    assert_equal expected, @handler.description
    assert_equal nil, @handler.url
  end

  def test_handle_alert
    @handler.mail = util_mail :subject => "Your HSBC eStatement is ready to be viewed",
                              :body => <<-BODY
Dear ERIC,

Your September 20, 2007 HSBC statement for your HSBC Direct 
Account ending: 6260 is now available online. 
To view your eStatement, go to www.hsbcdirect.com, log-on via 
"Account Access", and click on eStatements. Your online account 
statement will be available for up to 12 months through HSBC Direct 
Internet Banking.

If you have any questions, please call our 
Customer Relationship Center at 1-888-404-4050. Representatives 
are available to help you 24 hours a day, 7 days a week.

Thank you for growing your money with HSBC Direct.

Your HSBC Direct Customer Service Team
    BODY

    @handler.handle_alert

    expected = <<-EXPECTED.strip
Your September 20, 2007 HSBC statement for your HSBC Direct \r
Account ending: 6260 is now available online. \r
To view your eStatement, go to www.hsbcdirect.com, log-on via \r
\"Account Access\", and click on eStatements. Your online account \r
statement will be available for up to 12 months through HSBC Direct \r
Internet Banking.
    EXPECTED

    assert_equal expected, @handler.description
    assert_equal nil, @handler.url
  end

  def test_handle_hsbc
    @handler.mail = util_mail :body => <<-BODY
Please add hsbc@email.hsbcusa.com to your address book 
to ensure email delivery. 
   
Dear Eric Hodel,

You requested to be notified when purchase exceeding a certain dollar amount 
had posted to your HSBC Credit Card Account. The transactions described 
below exceed that dollar amount. 

Description: PURCHASE NAME 

Amount: $ 0000000.00 

You can log in to your Account to view 
your recent transactions 24 hours a day at hsbccreditcard.com.

Thank you,

		
HSBC Credit Card Customer Care
    BODY

    @handler.handle_hsbc

    expected = <<-EXPECTED
<p>Your purchase of PURCHASE NAME was for $0000000.00 which exceeds your
notification limit
    EXPECTED

    assert_equal expected, @handler.description
    assert_equal nil, @handler.url
  end

end

