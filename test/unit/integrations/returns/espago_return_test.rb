require 'test_helper'
require 'espago_test_helper'

class EspagoReturnTest < ActiveSupport::TestCase
  include ActiveMerchant::Billing::Integrations::Espago

  def test_empty_response_should_not_create_valid_return
    r = Return.new("<response><node></node></response>")
    assert !r.valid?
  end

  def test_valid_response_should_create_valid_return
    sale = Return.new(VALID_SALE_RESPONSE, :ip => EspagoConfig["ip"])
    assert sale.valid?
    get_status = Return.new(VALID_GET_STATUS_RESPONSE, :ip => EspagoConfig["ip"])
    assert get_status.valid?
    recurring_start = Return.new(VALID_RECURRING_START_RESPONSE, :ip => EspagoConfig["ip"])
    assert recurring_start.valid?
    recurring_status = Return.new(VALID_RECURRING_STATUS_RESPONSE, :ip => EspagoConfig["ip"])
    assert recurring_status.valid?
    recurring_update = Return.new(VALID_RECURRING_UPDATE_RESPONSE, :ip => EspagoConfig["ip"])
    assert recurring_update.valid?
    preauth = Return.new(VALID_PREAUTH_RESPONSE, :ip => EspagoConfig["ip"])
    assert preauth.valid?
    capture = Return.new(VALID_CAPTURE_RESPONSE, :ip => EspagoConfig["ip"])
    assert capture.valid?
    recurring_stop = Return.new(VALID_RECURRING_STOP_RESPONSE, :ip => EspagoConfig["ip"])
    assert recurring_stop.valid?
  end

  def test_valid_response_should_create_invalid_return_without_ip
    sale = Return.new(VALID_SALE_RESPONSE)
    assert !sale.valid?
    get_status = Return.new(VALID_GET_STATUS_RESPONSE)
    assert !get_status.valid?
    recurring_start = Return.new(VALID_RECURRING_START_RESPONSE)
    assert !recurring_start.valid?
    recurring_status = Return.new(VALID_RECURRING_STATUS_RESPONSE)
    assert !recurring_status.valid?
    recurring_update = Return.new(VALID_RECURRING_UPDATE_RESPONSE)
    assert !recurring_update.valid?
    preauth = Return.new(VALID_PREAUTH_RESPONSE)
    assert !preauth.valid?
    capture = Return.new(VALID_CAPTURE_RESPONSE)
    assert !capture.valid?
    recurring_stop = Return.new(VALID_RECURRING_STOP_RESPONSE)
    assert !recurring_stop.valid?
  end

  def test_valid_response_should_create_invalid_return_with_incorrect_ip
    sale = Return.new(VALID_SALE_RESPONSE, :ip => "127.0.0.1")
    assert !sale.valid?
    get_status = Return.new(VALID_GET_STATUS_RESPONSE, :ip => "127.0.0.1")
    assert !get_status.valid?
    recurring_start = Return.new(VALID_RECURRING_START_RESPONSE, :ip => "127.0.0.1")
    assert !recurring_start.valid?
    recurring_status = Return.new(VALID_RECURRING_STATUS_RESPONSE, :ip => "127.0.0.1")
    assert !recurring_status.valid?
    recurring_update = Return.new(VALID_RECURRING_UPDATE_RESPONSE, :ip => "127.0.0.1")
    assert !recurring_update.valid?
    preauth = Return.new(VALID_PREAUTH_RESPONSE, :ip => "127.0.0.1")
    assert !preauth.valid?
    capture = Return.new(VALID_CAPTURE_RESPONSE, :ip => "127.0.0.1")
    assert !capture.valid?
    recurring_stop = Return.new(VALID_RECURRING_STOP_RESPONSE, :ip => "127.0.0.1")
    assert !recurring_stop.valid?
  end

  def test_calculate_checksum
    sale = Return.new(VALID_SALE_RESPONSE)
    assert_equal sale.calculate_checksum, Digest::MD5.hexdigest("999999991some_session_idaccepted1303297377TestResponse1")
    get_status = Return.new(VALID_GET_STATUS_RESPONSE)
    assert_equal get_status.calculate_checksum, Digest::MD5.hexdigest("999999991725411585approved1304589448TestResponse1")
    recurring_start = Return.new(VALID_RECURRING_START_RESPONSE)
    assert_equal recurring_start.calculate_checksum, Digest::MD5.hexdigest("999999991some_session_idnew1305781394TestResponse1")
    recurring_status = Return.new(VALID_RECURRING_STATUS_RESPONSE)
    assert_equal recurring_status.calculate_checksum, Digest::MD5.hexdigest("9999999911234active5678TestResponse1")
    recurring_update = Return.new(VALID_RECURRING_UPDATE_RESPONSE)
    assert_equal recurring_update.calculate_checksum, Digest::MD5.hexdigest("999999991123456active1306314732TestResponse1")
    preauth = Return.new(VALID_PREAUTH_RESPONSE)
    assert_equal preauth.calculate_checksum, Digest::MD5.hexdigest("999999991some_session_idaccepted1307964315TestResponse1")
    capture = Return.new(VALID_CAPTURE_RESPONSE)
    assert_equal capture.calculate_checksum, Digest::MD5.hexdigest("999999991286708751approved1308045951TestResponse1")
    recurring_stop = Return.new(VALID_RECURRING_STOP_RESPONSE)
    assert_equal recurring_stop.calculate_checksum, Digest::MD5.hexdigest("999999991123456deactivated1306314732TestResponse1")
  end

  def test_success?
    sale = Return.new(VALID_SALE_RESPONSE, :ip => EspagoConfig["ip"])
    assert sale.success?
    sale = Return.new(
      VALID_SALE_RESPONSE.gsub("<status>accepted</status>", "<status>declined</status>"),
      :ip => EspagoConfig["ip"])
    sale.stubs(:valid?).returns(true)
    assert !sale.success?
    get_status = Return.new(VALID_GET_STATUS_RESPONSE, :ip => EspagoConfig["ip"])
    assert get_status.success?
    get_status = Return.new(
      VALID_GET_STATUS_RESPONSE.gsub("<status>approved</status>", "<status>accepted</status>"),
      :ip => EspagoConfig["ip"])
    get_status.stubs(:valid?).returns(true)
    assert !get_status.success?
    recurring_start = Return.new(VALID_RECURRING_START_RESPONSE, :ip => EspagoConfig["ip"])
    assert recurring_start.success?
    recurring_start = Return.new(
      VALID_RECURRING_START_RESPONSE.gsub("<status>new</status>", "<status>declined</status>"),
      :ip => EspagoConfig["ip"]
    )
    recurring_start.stubs(:valid?).returns(true)
    assert !recurring_start.success?
    recurring_status = Return.new(VALID_RECURRING_STATUS_RESPONSE, :ip => EspagoConfig["ip"])
    assert_raise(StandardError) { recurring_status.success? }
    preauth = Return.new(VALID_PREAUTH_RESPONSE, :ip => EspagoConfig["ip"])
    assert preauth.success?
    preauth = Return.new(
      VALID_PREAUTH_RESPONSE.gsub("<status>accepted</status>", "<status>declined</status>"),
      :ip => EspagoConfig["ip"])
    preauth.stubs(:valid?).returns(true)
    assert !preauth.success?
    capture = Return.new(VALID_CAPTURE_RESPONSE, :ip => EspagoConfig["ip"])
    assert capture.success?
    capture = Return.new(
      VALID_CAPTURE_RESPONSE.gsub("<status>approved</status>", "<status>declined</status>"),
      :ip => EspagoConfig["ip"])
    capture.stubs(:valid?).returns(true)
    assert !capture.success?
    recurring_stop = Return.new(VALID_RECURRING_STOP_RESPONSE, :ip => EspagoConfig["ip"])
    assert recurring_stop.success?
    recurring_stop = Return.new(
      VALID_RECURRING_STOP_RESPONSE.gsub("<status>deactivated</status>", "<status>active</status>"),
      :ip => EspagoConfig["ip"]
    )
    recurring_stop.stubs(:valid? => true)
    assert !recurring_stop.success?
  end

  def test_redirect_url
    sale = Return.new(VALID_SALE_RESPONSE)
    assert_equal sale.redirect_url, "https://sandbox.espago.com/en/transactions/639923858"
    get_status = Return.new(VALID_GET_STATUS_RESPONSE)
    assert_equal get_status.redirect_url, nil
    recurring_start = Return.new(VALID_RECURRING_START_RESPONSE)
    assert_equal recurring_start.redirect_url, "https://sandbox.espago.com/en/transactions/764714872"
    recurring_status = Return.new(VALID_RECURRING_STATUS_RESPONSE)
    assert_equal recurring_status.redirect_url, nil
    preauth = Return.new(VALID_PREAUTH_RESPONSE)
    assert_equal preauth.redirect_url, "https://sandbox.espago.com/en/transactions/307663319"
    capture = Return.new(VALID_CAPTURE_RESPONSE)
    assert_equal capture.redirect_url, nil
  end

  def test_recurring_info
    recurring_status = Return.new(VALID_RECURRING_STATUS_RESPONSE)
    assert_equal recurring_status.payments_count, "1"
    assert_equal recurring_status.last_successful_transaction, {"transaction_id"=>"778924173", "date"=>"2011-05-19", "status"=>"approved"}
  end
end
