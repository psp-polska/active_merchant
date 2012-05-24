require File.dirname(__FILE__) + '/espago/notification.rb'
require File.dirname(__FILE__) + '/espago/espago_request.rb'
require File.dirname(__FILE__) + '/espago/return.rb'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Espago

        def self.notification(post)
          Notification.new(post)
        end
      end
    end
  end
end
