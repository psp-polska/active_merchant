$espago_config = YAML.load_file(File.join(File.dirname(__FILE__), "espago.yml"))

class ActiveSupport::TestCase


  def espago_test_data
    output_hash = {
      :sale => {
        :session_id => sale_session_id = SecureRandom.hex(10),
        :request => {
          :action => 'sale',
          :amount => 100,
          :currency => 'PLN',
          :title => "Title #{sale_session_id}",
          :session_id => sale_session_id,
          :email => 'email@example.com',
          :first_name => 'John',
          :last_name => 'Smith',
          :client_ip => '127.0.0.1'
        }
      }
    }
    output_hash.merge!(
      :recurring_start => {
        :session_id => recurring_session_id = SecureRandom.hex(10),
        :request => output_hash[:sale][:request].merge(
          :action => 'recurring_start',
          :cycle => '1m',
          :max_amount => 100,
          :session_id => recurring_session_id
        )
      },
      :preauth => {
        :session_id => preauth_session_id = SecureRandom.hex(10),
        :request=> output_hash[:sale][:request].merge(
          :action => 'preauth',
          :session_id => preauth_session_id
        )
      }
    )
  end


  VALID_SALE_RESPONSE = "<?xml version='1.0' encoding='UTF-8'?>
  <response>
    <action>sale</action>
    <app-id>999999991</app-id>
    <session-id>some_session_id</session-id>
    <title>bzdet</title>
    <amount>100</amount>
    <transaction-id>639923858</transaction-id>
    <status>accepted</status>
    <checksum>#{Digest::MD5::hexdigest($espago_config['app_id'] + '639923858' + 'accepted' + '1303297377' + $espago_config['key_response'])}</checksum>
    <ts>1303297377</ts>
    <aux-data nil='true'></aux-data>
    <redirect-url>https://sandbox.espago.com/en/transactions/639923858</redirect-url>
  </response>"

  VALID_PREAUTH_RESPONSE = "<?xml version='1.0' encoding='UTF-8'?>
  <response>
    <action>preauth</action>
    <app-id>999999991</app-id>
    <session-id>some_session_id</session-id>
    <title>bzdet</title>
    <amount>100</amount>
    <ts>1307964315</ts>
    <checksum>#{Digest::MD5.hexdigest($espago_config['app_id'] + '307663319' + 'accepted' + '1307964315' + $espago_config['key_response'])}</checksum>
    <transaction-id>307663319</transaction-id>
    <status>accepted</status>
    <aux-data nil='true'></aux-data>
    <redirect-url>https://sandbox.espago.com/en/transactions/307663319</redirect-url>
  </response>"

  VALID_GET_STATUS_RESPONSE = "<?xml version='1.0' encoding='UTF-8'?>
  <response>
    <action>get_status</action>
    <app-id>999999991</app-id>
    <transaction-id>725411585</transaction-id>
    <ts>1304589448</ts>
    <checksum>#{Digest::MD5.hexdigest($espago_config['app_id'] + '725411585' + 'approved' + '1304589448' + $espago_config['key_response'])}</checksum>
    <amount>1000</amount>
    <currency>EUR</currency>
    <title>Transaction 725411585</title>
    <session-id>ses45601</session-id>
    <status>approved</status>
    <aux-data></aux-data>
  </response>"

  VALID_RECURRING_START_RESPONSE = "<?xml version='1.0' encoding='UTF-8'?>
  <response>
    <action>recurring_start</action>
    <app-id>999999991</app-id>
    <session-id>some_session_id</session-id>
    <transaction-id>764714872</transaction-id>
    <title>bzdet</title>
    <amount>100</amount>
    <ts>1305781394</ts>
    <checksum>#{Digest::MD5.hexdigest($espago_config['app_id'] + '716629090' + 'new' + '1305781394' + $espago_config['key_response'])}</checksum>
    <recurring-id>716629090</recurring-id>
    <status>new</status>
    <redirect-url>https://sandbox.espago.com/en/transactions/764714872</redirect-url>
  </response>"

  VALID_RECURRING_STATUS_RESPONSE = "<?xml version='1.0' endcoding='UTF-8'?>
  <response>
    <action>recurring_status</action>
    <app-id>999999991</app-id>
    <recurring-id>1234</recurring-id>
    <ts>5678</ts>
    <checksum>#{Digest::MD5.hexdigest($espago_config['app_id'] + '1234' + 'active' + '5678' + $espago_config['key_response'])}</checksum>
    <amount>125</amount>
    <currency>PLN</currency>
    <title>Something</title>
    <session-id>40f9bf98ff04b495</session-id>
    <aux-data nil='true'></aux-data>
    <status>active</status>
    <payments-count type='integer'>1</payments-count>
    <last-successful-transaction>
      <transaction-id>778924173</transaction-id>
      <status>approved</status>
      <date>2011-05-19</date>
    </last-successful-transaction>
  </response>"

  VALID_RECURRING_STOP_RESPONSE = "<?xml version='1.0' encoding='UTF-8'?>
  <response>
  	  <action>recurring_stop</action>
  	  <app-id>999999991</app-id>
  	  <recurring-id>123456</recurring-id>
  	  <ts>1306314732</ts>
  	  <checksum>#{Digest::MD5.hexdigest($espago_config['app_id'] + '123456' + 'deactivated' + '1306314732' + $espago_config['key_response'])}</checksum>
  	  <status>deactivated</status>
  	  <amount>1000.0</amount>
  	  <currency>PLN</currency>
  	  <title>Recurring 706631045</title>
  	  <session-id>ses45011</session-id>
  </response>"

  VALID_RECURRING_UPDATE_RESPONSE = "<?xml version='1.0'encoding='UTF-8'?>
  <response>
    <action>recurring_update</action>
    <app-id>999999991</app-id>
    <recurring-id>123456</recurring-id>
    <ts>1306314732</ts>
    <checksum>#{Digest::MD5.hexdigest($espago_config['app_id'] + '123456' + 'active' + '1306314732' + $espago_config['key_response'])}</checksum>
    <status>active</status>
    <amount>10.0</amount>
    <currency>EUR</currency>
    <title>Hosting</title>
    <session-id>d01102550ecef3a1</session-id>
    <aux-data></aux-data>
  </response>
  "

  VALID_CAPTURE_RESPONSE = "<?xml version='1.0' encoding='UTF-8'?>
  <response>
    <action>capture</action>
    <app-id>999999991</app-id>
    <transaction-id>286708751</transaction-id>
    <ts>1308045951</ts>
    <checksum>#{Digest::MD5.hexdigest($espago_config['app_id'] + '286708751' + 'approved' + '1308045951' + $espago_config['key_response'])}</checksum>
    <status>approved</status>
  </response>"


  VALID_SALE = "<?xml version='1.0' encoding='UTF-8'?>
  <response>
    <action>sale</action>
    <app-id>999999991</app-id>
    <session-id>some_session_id</session-id>
    <title>bzdet</title>
    <amount>100</amount>
    <currency>EUR</currency>
    <transaction-id>639923858</transaction-id>
    <status>approved</status>
    <checksum>64a0ac4a8f9899c89e11657122b3c39e</checksum>
    <ts>1303297377</ts>
  </response>"

  VALID_PREAUTH = "<?xml version='1.0' encoding='UTF-8'?>
  <response>
    <action>preauth</action>
    <app-id>999999991</app-id>
    <session-id>some_session_id</session-id>
    <title>bzdet</title>
    <amount>100</amount>
    <currency>EUR</currency>
    <transaction-id>639923858</transaction-id>
    <status>approved</status>
    <checksum>64a0ac4a8f9899c89e11657122b3c39e</checksum>
    <ts>1303297377</ts>
  </response>"

  VALID_CAPTURE = VALID_CAPTURE_RESPONSE

  VALID_RECURRING_START = "<?xml version='1.0' encoding='UTF-8'?>
  <response>
    <action>recurring_start</action>
    <app-id>999999991</app-id>
    <recurring-id>798255172</recurring-id>
    <ts>1306248938</ts>
    <checksum>02780b71c9da20d4448ba9c1cb25c6c1</checksum>
    <amount>125</amount>
    <currency>PLN</currency>
    <title>Something</title>
    <session-id>40f9bf98ff04b495</session-id>
    <status>active</status>
    <payments-count>0</payments-count>
  </response>"

  VALID_RECURRING_STOP = "<?xml version='1.0' encoding='UTF-8'?>
  <response>
    <app-id>999999991</app-id>
  	<action>recurring_stop</action>
  	<recurring_id>12345</recurring_id>
  	<title>Something</title>
  	<amount>125</amount>
    <currency>PLN</currency>
  	<checksum>3b72b67e8e9f059d94736b071bf10b8a</checksum>
    <ts>098765</ts>
   	<status>deactivated</status>
  </response>"

 VALID_SALE_REQUEST_PARAMS =  {:action => "sale", :amount => 100, :currency => "EUR", :title => "bzdet", :session_id => "some_session_id", :email => "email@example.com", :first_name => "John", :last_name => "Smith", :client_ip => "127.0.0.1"}

  VALID_STATUS_REQUEST_PARAMS = {:action => "get_status", :transaction_id => "666"}

  VALID_RECURRING_START_REQUEST_PARAMS = VALID_SALE_REQUEST_PARAMS.merge(:action => "recurring_start", :cycle => "1m", :max_amount => 100)

  VALID_RECURRING_STOP_REQUEST_PARAMS = {:action => "recurring_stop", :recurring_id => 777}

  VALID_RECURRING_STATUS_REQUEST_PARAMS = {:action => "recurring_status", :recurring_id => 1234}

  VALID_RECURRING_UPDATE_REQUEST_PARAMS = VALID_SALE_REQUEST_PARAMS.merge(:recurring_id => 1234, :action => "recurring_update", :amount => 50)

  VALID_PREAUTH_REQUEST_PARAMS = VALID_SALE_REQUEST_PARAMS.merge(:action => "preauth")

  VALID_CAPTURE_REQUEST_PARAMS = {:action => "capture", :transaction_id => "123456" }

end
