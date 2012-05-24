require 'net/http'
require 'digest/md5'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Espago
        class Notification < ActiveMerchant::Billing::Integrations::Notification

          def calculate_checksum
            Digest::MD5::hexdigest(params["app_id"] + checksum_field + params["status"] + params["ts"] + EspagoConfig['key_response'])
          end

          def checksum_field
            if ['recurring_start', 'recurring_stop', 'recurring_status'].include?(action)
              recurring_id
            else
              transaction_id
            end
          end

          def valid?
            params and valid_app_id? and valid_checksum?
          end

          def complete?
            return false unless valid?
            return true if (["sale", "preauth", "capture"].include?(action) and status == "approved") or
              (action == "recurring_start" and status == "active") or
              (action == "recurring_stop" and status == "deactivated")
            false
          end

          def transaction_id
            params['transaction_id'] || params['recurring_id']
          end

          def session_id
            params['session_id']
          end

          def recurring_id
            params['recurring_id']
          end

          # When was this payment received by the client.
          def received_at
            Time.at(params['ts'].to_i)
          end

          # the money amount we received in X.2 decimal.
          def gross
            "%.2f" % (gross_cents / 100.0)
          end

          def gross_cents
            params['amount'].to_i
          end

          def currency
            params['currency']
          end

          def action
            params['action']
          end

          def status
            params['status']
          end

          def test?
            ActiveMerchant::Billing::Base.integration_mode == :test
          end

          # Acknowledge the transaction to Espago. This method has to be called after a new
          # apc arrives. Espago will verify that all the information we received are correct and will return a
          # ok or a fail.
          #
          # Example:
          #
          #   def ipn
          #     notify = EspagoNotification.new(request.raw_post)

          #     if notify.acknowledge
          #       ... process order ... if notify.complete?
          #     else
          #       ... log possible hacking attempt ...
          #     end
          def acknowledge
            request = EspagoRequest.new(acknowledge_request_options)
            res = request.send
            ret = Return.new(res.body, :ip => IPSocket::getaddress(EspagoConfig['domain']))
            if ['capture', 'sale'].include?(self.action)
              ret.success?
            elsif ['recurring_start', 'recurring_stop'].include?(self.action)
              self.status == ret.status
            else
              raise StandardError, "Not supported action #{self.action}"
            end
          end
 private

          # Take the posted xml data and move the relevant data into a hash
          def parse(post)
            @params = Hash.from_xml(post)["response"].inject({}) {|h, (k, v)| h.merge(k => v.to_s)}
          end

          def valid_checksum?
            params["checksum"] == calculate_checksum
          end

          def valid_app_id?
            params["app_id"] == EspagoConfig["app_id"]
          end

          def acknowledge_request_options
            case action
            when "sale", "preauth", "capture"
              {:action => "get_status", :transaction_id => transaction_id}
            when "recurring_start", "recurring_stop"
              {:action => "recurring_status", :recurring_id => transaction_id}
            else
              raise StandardError, "Invalid action: #{action}"
            end
          end

        end
      end
    end
  end
end
