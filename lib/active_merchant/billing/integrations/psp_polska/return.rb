require "digest/md5"

module ActiveMerchant
  module Billing
    module Integrations
      module PspPolska

        class Return < ActiveMerchant::Billing::Integrations::Return

          def valid?
            params and valid_app_id? and valid_ip? and valid_checksum?
          end

          def success?
            return false unless valid?
            if ["sale", "preauth"].include?(action)
              return true if status == "accepted"
            elsif ["get_status", "capture"].include?(action)
              return true if status == "approved"
            elsif action == "recurring_start"
              return true if status == "new"
            elsif action == "recurring_status"
              raise StandardError, "success? method is not available for recurring_status. Pleasy use status method"
            elsif action == "recurring_stop"
              return true if status == "deactivated"
            elsif action == "recurring_update"
              return true if status == "recurring_update"
            else
              action_not_implemented_error
            end
            false
          end

          def status
            params["status"]
          end

          def redirect_url
            params["redirect_url"]
          end

          def transaction_id
            params["transaction_id"]
          end

          def recurring_id
            params["recurring_id"]
          end

          def action
            params["action"]
          end

          def payments_count
            params["payments_count"]
          end

          def last_successful_transaction
            params["last_successful_transaction"]
          end

          def calculate_checksum
            if ["sale", "preauth", "recurring_start"].include?(action)
              Digest::MD5::hexdigest(params["app_id"] + params["session_id"] + params["status"] + params["ts"] + PspPolskaConfig['key_response'])
            elsif ["get_status", "capture"].include?(action)
              Digest::MD5::hexdigest(params["app_id"] + params["transaction_id"] + params["status"] + params["ts"] + PspPolskaConfig['key_response'])
            elsif ["recurring_status", "recurring_stop","recurring_update"].include?(action)
              Digest::MD5::hexdigest(params["app_id"] + params["recurring_id"] + params["status"] + params["ts"] + PspPolskaConfig['key_response'])
            else
              action_not_implemented_error
            end
          end

          private

          def parse(query_string)
            Hash.from_xml(query_string)["response"].inject({}) {|h, (k, v)| h.merge(k => v.is_a?(Hash) ? v : v.to_s)}
          end

          def valid_app_id?
            params["app_id"] == PspPolskaConfig['app_id']
          end

          def valid_checksum?
            params["checksum"] == calculate_checksum
          end

          def valid_ip?
            @options and @options[:ip] == PspPolskaConfig['ip']
          end

          def action_not_implemented_error
            raise StandardError, "Action not implemnted yet: #{action}"
          end
        end
      end
    end
  end
end
