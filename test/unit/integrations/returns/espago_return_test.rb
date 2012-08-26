require 'test_helper'
require 'espago_test_helper'

class EspagoReturnTest < ActiveSupport::TestCase
  include ActiveMerchant::Billing::Integrations::Espago

  def test_empty_response_should_not_create_valid_return
    r = Return.new("<response><node></node></response>")
    assert !r.valid?
  end

  def test_valid_response_should_create_valid_return
    sale = Return.new(VALID_SALE_RESPONSE, :ip => $espago_config["ip"])
    assert sale.valid?
    get_status = Return.new(VALID_GET_STATUS_RESPONSE, :ip => $espago_config["ip"])
    assert get_status.valid?
    recurring_start = Return.new(VALID_RECURRING_START_RESPONSE, :ip => $espago_config["ip"])
    assert recurring_start.valid?
    recurring_status = Return.new(VALID_RECURRING_STATUS_RESPONSE, :ip => $espago_config["ip"])
    assert recurring_status.valid?
    recurring_update = Return.new(VALID_RECURRING_UPDATE_RESPONSE, :ip => $espago_config["ip"])
    assert recurring_update.valid?
    preauth = Return.new(VALID_PREAUTH_RESPONSE, :ip => $espago_config["ip"])
    assert preauth.valid?
    capture = Return.new(VALID_CAPTURE_RESPONSE, :ip => $espago_config["ip"])
    assert capture.valid?
    recurring_stop = Return.new(VALID_RECURRING_STOP_RESPONSE, :ip => $espago_config["ip"])
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
    assert_equal sale.calculate_checksum, Digest::MD5.hexdigest($espago_config['app_id'] + '639923858' + 'accepted' + '1303297377' + $espago_config['key_response'])
    get_status = Return.new(VALID_GET_STATUS_RESPONSE)
    assert_equal get_status.calculate_checksum, Digest::MD5.hexdigest($espago_config['app_id'] + '725411585' + 'approved' + '1304589448' + $espago_config['key_response'])
    recurring_start = Return.new(VALID_RECURRING_START_RESPONSE)
    assert_equal recurring_start.calculate_checksum, Digest::MD5.hexdigest($espago_config['app_id'] + '716629090' + 'new' + '1305781394' + $espago_config['key_response'])
    recurring_status = Return.new(VALID_RECURRING_STATUS_RESPONSE)
    assert_equal recurring_status.calculate_checksum, Digest::MD5.hexdigest($espago_config['app_id'] + '1234' + 'active' + '5678' + $espago_config['key_response'])
    recurring_update = Return.new(VALID_RECURRING_UPDATE_RESPONSE)
    assert_equal recurring_update.calculate_checksum, Digest::MD5.hexdigest($espago_config['app_id'] + '123456' + 'active' + '1306314732' + $espago_config['key_response'])
    preauth = Return.new(VALID_PREAUTH_RESPONSE)
    assert_equal preauth.calculate_checksum, Digest::MD5.hexdigest($espago_config['app_id'] + '307663319' + 'accepted' + '1307964315' + $espago_config['key_response'])
    capture = Return.new(VALID_CAPTURE_RESPONSE)
    assert_equal capture.calculate_checksum, Digest::MD5.hexdigest($espago_config['app_id'] + '286708751' + 'approved' + '1308045951' + $espago_config['key_response'])
    recurring_stop = Return.new(VALID_RECURRING_STOP_RESPONSE)
    assert_equal recurring_stop.calculate_checksum, Digest::MD5.hexdigest($espago_config['app_id'] + '123456' + 'deactivated' + '1306314732' + $espago_config['key_response'])
  end

  def test_success?
    sale = Return.new(VALID_SALE_RESPONSE, :ip => $espago_config["ip"])
    assert sale.success?
    sale = Return.new(
      VALID_SALE_RESPONSE.gsub("<status>accepted</status>", "<status>declined</status>"),
      :ip => $espago_config["ip"])
    sale.stubs(:valid?).returns(true)
    assert !sale.success?
    get_status = Return.new(VALID_GET_STATUS_RESPONSE, :ip => $espago_config["ip"])
    assert get_status.success?
    get_status = Return.new(
      VALID_GET_STATUS_RESPONSE.gsub("<status>approved</status>", "<status>accepted</status>"),
      :ip => $espago_config["ip"])
    get_status.stubs(:valid?).returns(true)
    assert !get_status.success?
    recurring_start = Return.new(VALID_RECURRING_START_RESPONSE, :ip => $espago_config["ip"])
    assert recurring_start.success?
    recurring_start = Return.new(
      VALID_RECURRING_START_RESPONSE.gsub("<status>new</status>", "<status>declined</status>"),
      :ip => $espago_config["ip"]
    )
    recurring_start.stubs(:valid?).returns(true)
    assert !recurring_start.success?
    recurring_status = Return.new(VALID_RECURRING_STATUS_RESPONSE, :ip => $espago_config["ip"])
    assert_raise(StandardError) { recurring_status.success? }
    preauth = Return.new(VALID_PREAUTH_RESPONSE, :ip => $espago_config["ip"])
    assert preauth.success?
    preauth = Return.new(
      VALID_PREAUTH_RESPONSE.gsub("<status>accepted</status>", "<status>declined</status>"),
      :ip => $espago_config["ip"])
    preauth.stubs(:valid?).returns(true)
    assert !preauth.success?
    capture = Return.new(VALID_CAPTURE_RESPONSE, :ip => $espago_config["ip"])
    assert capture.success?
    capture = Return.new(
      VALID_CAPTURE_RESPONSE.gsub("<status>approved</status>", "<status>declined</status>"),
      :ip => $espago_config["ip"])
    capture.stubs(:valid?).returns(true)
    assert !capture.success?
    recurring_stop = Return.new(VALID_RECURRING_STOP_RESPONSE, :ip => $espago_config["ip"])
    assert recurring_stop.success?
    recurring_stop = Return.new(
      VALID_RECURRING_STOP_RESPONSE.gsub("<status>deactivated</status>", "<status>active</status>"),
      :ip => $espago_config["ip"]
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
