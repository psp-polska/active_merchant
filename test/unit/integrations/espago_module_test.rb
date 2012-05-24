require 'test_helper'

class EspagoModuleTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def test_notification_method
    assert_instance_of Espago::Notification, Espago.notification('<response><key>value</key></response>')
  end
end
