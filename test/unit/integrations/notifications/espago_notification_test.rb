require 'test_helper'
require 'espago_test_helper'
require 'digest/md5'

class EspagoNotificationTest < ActiveSupport::TestCase
  include ActiveMerchant::Billing::Integrations::Espago

  def setup
    @sale = Notification.new(VALID_SALE)
    @recurring_start = Notification.new(VALID_RECURRING_START)
    @recurring_stop = Notification.new(VALID_RECURRING_STOP)
    @preauth = Notification.new(VALID_PREAUTH)
    @capture = Notification.new(VALID_CAPTURE)
  end

  def test_initializer
    assert_equal @sale.params.size, 10
    assert_equal @recurring_start.params.size, 11
    assert_equal @recurring_stop.params.size, 9
    assert_equal @preauth.params.size, 10
    assert_equal @capture.params.size, 6
  end

  def test_calculate_checksum
    assert_equal @sale.calculate_checksum, Digest::MD5.hexdigest("999999991639923858approved1303297377TestResponse1")
    assert_equal @recurring_start.calculate_checksum, Digest::MD5.hexdigest("999999991798255172active1306248938TestResponse1")
    assert_equal @recurring_stop.calculate_checksum, Digest::MD5.hexdigest("99999999112345deactivated098765TestResponse1")
    assert_equal @preauth.calculate_checksum, Digest::MD5.hexdigest("999999991639923858approved1303297377TestResponse1")
     assert_equal @capture.calculate_checksum, Digest::MD5.hexdigest("999999991286708751approved1308045951TestResponse1")

  end

  def test_valid_with_correct_data
    assert @sale.valid?
    assert @recurring_start.valid?
    assert @recurring_stop.valid?
    assert @preauth.valid?
    assert @capture.valid?
  end

  def test_valid_with_incorrect_app_id
    @sale = Notification.new(VALID_SALE.gsub("<app-id>999999991</app-id>", "<app-id>incorrect</app-id>"), {:ip => $espago_config["ip"]})
    @recurring_start = Notification.new(VALID_RECURRING_START.gsub("<app-id>999999991</app-id>", "<app-id>incorrect</app-id>"), {:ip => $espago_config["ip"]})
    @recurring_stop = Notification.new(VALID_RECURRING_STOP.gsub("<app-id>999999991</app-id>", "<app-id>incorrect</app-id>"), {:ip => $espago_config["ip"]})
    @preauth = Notification.new(VALID_PREAUTH.gsub("<app-id>999999991</app-id>", "<app-id>incorrect</app-id>"), {:ip => $espago_config["ip"]})
    @capture = Notification.new(VALID_CAPTURE.gsub("<app-id>999999991</app-id>", "<app-id>incorrect</app-id>"), {:ip => $espago_config["ip"]})
    assert !@sale.valid?
    assert !@recurring_start.valid?
    assert !@recurring_stop.valid?
    assert !@preauth.valid?
    assert !@capture.valid?
  end

  def test_valid_with_incorrect_checksum
    @sale = Notification.new(VALID_SALE.gsub("<checksum>64a0ac4a8f9899c89e11657122b3c39e</checksum>", "<checksum>incorrect</checksum>"), {:ip => $espago_config["ip"]})
    @recurring_start = Notification.new(VALID_RECURRING_START.gsub("<checksum>02780b71c9da20d4448ba9c1cb25c6c1</checksum>", "<checksum>incorrect</checksum>"), {:ip => $espago_config["ip"]})
    @recurring_stop = Notification.new(VALID_RECURRING_STOP.gsub("<checksum>3b72b67e8e9f059d94736b071bf10b8a</checksum>", "<checksum>incorrect</checksum>"), {:ip => $espago_config["ip"]})
    @preauth = Notification.new(VALID_PREAUTH.gsub("<checksum>64a0ac4a8f9899c89e11657122b3c39e</checksum>", "<checksum>incorrect</checksum>"), {:ip => $espago_config["ip"]})
    @capture = Notification.new(VALID_CAPTURE.gsub("<checksum>8ed193ba33b64676d2a663fd7e7beefc</checksum>", "<checksum>incorrect</checksum>"), {:ip => $espago_config["ip"]})
    assert !@sale.valid?
    assert !@recurring_start.valid?
    assert !@recurring_stop.valid?
    assert !@preauth.valid?
    assert !@capture.valid?
  end

  def test_complete
    assert @sale.complete?
    @sale.stubs(:valid?).returns(false)
    assert !@sale.complete?
    @sale.stubs(:valid?).returns(true)
    @sale.stubs(:status).returns("decline")
    assert !@sale.complete?
    assert @recurring_start.complete?
    @recurring_start.stubs(:valid?).returns(false)
    assert !@recurring_start.complete?
    @recurring_start.stubs(:valid?).returns(true)
    @recurring_start.stubs(:status).returns("unauthorized")
    @recurring_start.complete?
    assert @recurring_stop.complete?
    @recurring_stop.stubs(:valid?).returns(false)
    assert !@recurring_stop.complete?
    @recurring_stop.stubs(:valid?).returns(true)
    @recurring_stop.stubs(:status).returns("active")
    assert !@recurring_stop.complete?
    assert @preauth.complete?
    @preauth.stubs(:valid?).returns(false)
    assert !@preauth.complete?
    @preauth.stubs(:valid?).returns(true)
    @preauth.stubs(:status).returns("decline")
    assert !@preauth.complete?
    assert @capture.complete?
    @capture.stubs(:valid?).returns(false)
    assert !@capture.complete?
    @capture.stubs(:valid?).returns(true)
    @capture.stubs(:status).returns("decline")
    assert !@capture.complete?
  end


  def test_accessors
    assert_equal "approved", @sale.status
    assert_equal "639923858", @sale.transaction_id
    assert_equal 100, @sale.gross_cents
    assert_equal "1.00", @sale.gross
    assert_equal "EUR", @sale.currency
    assert_equal Time.at("1303297377".to_i), @sale.received_at
    assert_equal "sale", @sale.action
    assert_equal "active", @recurring_start.status
    assert_equal "798255172", @recurring_start.transaction_id
    assert_equal 125, @recurring_start.gross_cents
    assert_equal "1.25", @recurring_start.gross
    assert_equal "PLN", @recurring_start.currency
    assert_equal Time.at("1306248938".to_i), @recurring_start.received_at
    assert_equal "recurring_start", @recurring_start.action
    assert_equal "deactivated", @recurring_stop.status
    assert_equal "12345", @recurring_stop.transaction_id
    assert_equal 125, @recurring_stop.gross_cents
    assert_equal "1.25", @recurring_stop.gross
    assert_equal "PLN", @recurring_stop.currency
    assert_equal Time.at("098765".to_i), @recurring_stop.received_at
    assert_equal "recurring_stop", @recurring_stop.action
    assert_equal "approved", @preauth.status
    assert_equal "639923858", @preauth.transaction_id
    assert_equal 100, @preauth.gross_cents
    assert_equal "1.00", @preauth.gross
    assert_equal "EUR", @preauth.currency
    assert_equal Time.at("1303297377".to_i), @preauth.received_at
    assert_equal "preauth", @preauth.action
    assert_equal "approved", @capture.status
    assert_equal "286708751", @capture.transaction_id
    assert_equal Time.at("1308045951".to_i), @capture.received_at
    assert_equal "capture", @capture.action
  end


  def test_compositions
    assert_equal Money.new(100, 'EUR'), @sale.amount
    assert_equal Money.new(125, 'PLN'), @recurring_start.amount
    assert_equal Money.new(125, 'PLN'), @recurring_stop.amount
    assert_equal Money.new(100, 'EUR'), @preauth.amount
  end

end
