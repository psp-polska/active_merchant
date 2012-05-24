require 'test_helper'
require 'espago_test_helper'
require 'digest/md5'

class EspagoRequestTest < ActiveSupport::TestCase
  include ActiveMerchant::Billing::Integrations::Espago

  def setup
    Time.stubs(:now).returns(555)
    @sale_request = EspagoRequest.new(VALID_SALE_REQUEST_PARAMS)
    @status_request = EspagoRequest.new(VALID_STATUS_REQUEST_PARAMS)
    @recurring_start_request = EspagoRequest.new(VALID_RECURRING_START_REQUEST_PARAMS)
    @recurring_stop_request = EspagoRequest.new(VALID_RECURRING_STOP_REQUEST_PARAMS)
    @recurring_status_request = EspagoRequest.new(VALID_RECURRING_STATUS_REQUEST_PARAMS)
    @recurring_update_request = EspagoRequest.new(VALID_RECURRING_UPDATE_REQUEST_PARAMS)
    @preauth_request = EspagoRequest.new(VALID_PREAUTH_REQUEST_PARAMS)
    @capture_request = EspagoRequest.new(VALID_CAPTURE_REQUEST_PARAMS)
  end

  def test_params_after_initialize
    assert @sale_request.params.has_key?(:version)
    ESPAGO_SALE_REQUEST_CHECKSUM_FIELDS.each do |key|
      assert @sale_request.params.has_key?(key)
    end
    assert !@sale_request.params.has_key?(:fake)
    assert @status_request.params.has_key?(:version)
    ESPAGO_STATUS_REQUEST_CHECKSUM_FIELDS.each do |key|
      assert @status_request.params.has_key?(key)
    end
    assert !@status_request.params.has_key?(:fake)
    assert @recurring_start_request.params.has_key?(:version)
    ESPAGO_RECURRING_START_REQUEST_CHECKSUM_FIELDS.each do |key|
      assert @recurring_start_request.params.has_key?(key)
    end
    assert !@recurring_start_request.params.has_key?(:fake)
    assert @recurring_stop_request.params.has_key?(:version)
    ESPAGO_RECURRING_STOP_REQUEST_CHECKSUM_FIELDS.each do |key|
      assert @recurring_stop_request.params.has_key?(key)
    end
    assert !@recurring_stop_request.params.has_key?(:fake)
    assert @recurring_status_request.params.has_key?(:version)
    ESPAGO_RECURRING_STATUS_REQUEST_CHECKSUM_FIELDS.each do |key|
      assert @recurring_status_request.params.has_key?(key)
    end
    assert !@recurring_status_request.params.has_key?(:fake)
    assert @recurring_update_request.params.has_key?(:version)
    ESPAGO_RECURRING_UPDATE_REQUEST_CHECKSUM_FIELDS.each do |key|
      assert @recurring_update_request.params.has_key?(key)
    end
    assert !@recurring_update_request.params.has_key?(:fake)
    assert @preauth_request.params.has_key?(:version)
    ESPAGO_PREAUTH_REQUEST_CHECKSUM_FIELDS.each do |key|
      assert @preauth_request.params.has_key?(key)
    end
    assert !@preauth_request.params.has_key?(:fake)
    assert @capture_request.params.has_key?(:version)
    ESPAGO_CAPTURE_REQUEST_CHECKSUM_FIELDS.each do |key|
      assert @capture_request.params.has_key?(key)
    end
    assert !@capture_request.params.has_key?(:fake)
  end

  def test_calculate_checksum
    @sale_request.calculate_checksum
    assert_equal @sale_request.params[:checksum], Digest::MD5.hexdigest("999999991salesome_session_id100JohnSmith127.0.0.1555TestRequest1")
    @status_request.calculate_checksum
    assert_equal @status_request.params[:checksum], Digest::MD5.hexdigest("999999991get_status666555TestRequest1")
    @recurring_start_request.calculate_checksum
    assert_equal @recurring_start_request.params[:checksum], Digest::MD5.hexdigest("999999991recurring_startsome_session_id100JohnSmith127.0.0.1555TestRequest1")
    @recurring_stop_request.calculate_checksum
    assert_equal @recurring_stop_request.params[:checksum], Digest::MD5.hexdigest("999999991recurring_stop777555TestRequest1")
    @recurring_status_request.calculate_checksum
    assert_equal @recurring_status_request.params[:checksum], Digest::MD5.hexdigest("999999991recurring_status1234555TestRequest1")
    @recurring_update_request.calculate_checksum
    assert_equal @recurring_update_request.params[:checksum], Digest::MD5.hexdigest("999999991recurring_update1234555TestRequest1")
    @preauth_request.calculate_checksum
    assert_equal @preauth_request.params[:checksum], Digest::MD5.hexdigest("999999991preauthsome_session_id100JohnSmith127.0.0.1555TestRequest1")
    @capture_request.calculate_checksum
    assert_equal @capture_request.params[:checksum], Digest::MD5.hexdigest("999999991capture123456555TestRequest1")
  end

  def test_load_fields_info
    assert_equal @sale_request.instance_variable_get(:@checksum_fields), ESPAGO_SALE_REQUEST_CHECKSUM_FIELDS
    assert_equal @status_request.instance_variable_get(:@checksum_fields), ESPAGO_STATUS_REQUEST_CHECKSUM_FIELDS
    assert_equal @recurring_start_request.instance_variable_get(:@checksum_fields), ESPAGO_RECURRING_START_REQUEST_CHECKSUM_FIELDS
    assert_equal @recurring_stop_request.instance_variable_get(:@checksum_fields), ESPAGO_RECURRING_STOP_REQUEST_CHECKSUM_FIELDS
    assert_equal @recurring_status_request.instance_variable_get(:@checksum_fields), ESPAGO_RECURRING_STATUS_REQUEST_CHECKSUM_FIELDS
    assert_equal @recurring_update_request.instance_variable_get(:@checksum_fields), ESPAGO_RECURRING_UPDATE_REQUEST_CHECKSUM_FIELDS
    assert_equal @preauth_request.instance_variable_get(:@checksum_fields), ESPAGO_PREAUTH_REQUEST_CHECKSUM_FIELDS
  end

  def test_set_type
    assert_equal @sale_request.set_type("sale"), :sale_request
    assert_equal @status_request.set_type("get_status"), :status_request
    assert_equal @recurring_start_request.set_type("recurring_start"), :recurring_start_request
    assert_equal @recurring_stop_request.set_type("recurring_stop"), :recurring_stop_request
    assert_equal @recurring_status_request.set_type("recurring_status"), :recurring_status_request
    assert_equal @recurring_status_request.set_type("recurring_update"), :recurring_update_request
    assert_equal @preauth_request.set_type("preauth"), :preauth_request
    assert_raise(ArgumentError) { @sale_request.set_type("fake")}
  end

end
