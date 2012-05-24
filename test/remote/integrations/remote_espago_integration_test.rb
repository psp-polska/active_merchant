require 'test_helper'
require 'espago_test_helper'

EspagoConfig = YAML.load_file(File.join(File.dirname(__FILE__), "../../espago_remote.yml"))

class RemoteEspagoIntegrationTest < ActiveSupport::TestCase
  include ActiveMerchant::Billing::Integrations::Espago

  def test_sale
    sale_setup
    assert @return.valid?
    assert_equal @return.action, "sale"
    assert_equal @return.status, "accepted"
    assert_equal @return.redirect_url, "https://sandbox.espago.com/en/transactions/#{@return.transaction_id}"
  end

  def test_get_status
    sale_setup
    @request = EspagoRequest.new(VALID_STATUS_REQUEST_PARAMS.merge(:transaction_id => @return.transaction_id))
    basic_setup
    assert @return.valid?
    assert_equal @return.action, "get_status"
    assert_equal @return.status, "accepted"
  end

  def test_recurring_start
    recurring_setup
    assert @return.valid?
    assert_equal @return.action, "recurring_start"
    assert_equal @return.status, "new"
    assert_equal @return.redirect_url, "https://sandbox.espago.com/en/recurring/#{@return.recurring_id}"
    assert @return.success?
  end

  def test_recurring_status
    recurring_setup
    @request = EspagoRequest.new(VALID_RECURRING_STATUS_REQUEST_PARAMS.merge(:recurring_id => @return.recurring_id))
    basic_setup
    assert @return.valid?
    assert_equal @return.action, "recurring_status"
    assert_equal @return.status, "new"
  end

  def test_preauth
    preauth_setup
    assert @return.valid?
    assert_equal @return.action, "preauth"
    assert_equal @return.status, "accepted"
    assert_equal @return.redirect_url, "https://sandbox.espago.com/en/transactions/#{@return.transaction_id}"
  end

  private

  def sale_setup
    @request = EspagoRequest.new(espago_test_data[:sale][:request])
    basic_setup
  end

  def preauth_setup
    @request = EspagoRequest.new(espago_test_data[:preauth][:request])
    basic_setup
  end

  def recurring_setup
    @request = EspagoRequest.new(espago_test_data[:recurring_start][:request])
    basic_setup
  end

  def basic_setup
    @response = @request.send
    @return = Return.new(@response.body, :ip => EspagoConfig["ip"])
  end

end
