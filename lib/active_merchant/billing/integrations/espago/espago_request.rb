require "digest/md5"
require "net/http"
require "net/https"

ESPAGO_SALE_REQUEST_CHECKSUM_FIELDS = [:app_id, :action, :session_id, :amount, :first_name, :last_name, :client_ip, :ts]
ESPAGO_STATUS_REQUEST_CHECKSUM_FIELDS = [:app_id, :action, :transaction_id, :ts]
ESPAGO_RECURRING_START_REQUEST_CHECKSUM_FIELDS = ESPAGO_SALE_REQUEST_CHECKSUM_FIELDS
ESPAGO_RECURRING_STOP_REQUEST_CHECKSUM_FIELDS = [:app_id, :action, :recurring_id, :ts]
ESPAGO_RECURRING_STATUS_REQUEST_CHECKSUM_FIELDS = ESPAGO_RECURRING_STOP_REQUEST_CHECKSUM_FIELDS
ESPAGO_RECURRING_UPDATE_REQUEST_CHECKSUM_FIELDS = [:app_id, :action, :recurring_id, :ts]
ESPAGO_PREAUTH_REQUEST_CHECKSUM_FIELDS = ESPAGO_SALE_REQUEST_CHECKSUM_FIELDS
ESPAGO_CAPTURE_REQUEST_CHECKSUM_FIELDS = [:app_id, :action, :transaction_id, :ts]

module ActiveMerchant
  module Billing
    module Integrations
      module Espago

        class EspagoRequest

          attr_accessor :params

          def initialize(options = {})
            options[:app_id] ||= $espago_config['app_id']
            options[:ts] ||= Time.now.to_i
            set_type(options[:action])
            load_fields_info
            @params = {}
            @params[:version] = options[:version] || 1.0
            options.each do |key, value|
              @params[key] = value.to_s
            end
          end

          def calculate_checksum
            string = @checksum_fields.map{|field| @params[field]}.join + $espago_config['key_request']
            params[:checksum] = Digest::MD5.hexdigest(string)
          end

          def to_xml
            calculate_checksum
            @params.delete_if { |key, value| key == 'app_id' }.to_xml(:root => "request")
          end

          def send
            url = URI.parse($espago_config['request_uri'])
            http = Net::HTTP.new(url.host, url.port)
            http.use_ssl = true
            request = Net::HTTP::Post.new(url.path)
            request.content_type = "text/xml"
            request.basic_auth $espago_config['app_id'], $espago_config['password']
            request.body = self.to_xml
            http.start{|http| http.request(request)}
          end

          def load_fields_info
            checksum_fields_const_name = "ESPAGO_" + @type.to_s.upcase + "_CHECKSUM_FIELDS"
            if Object.const_defined?(checksum_fields_const_name)
              @checksum_fields = checksum_fields_const_name.constantize
            else
              raise ArgumentError, "Wrong request type: #{@type}"
            end
          end

          def set_type(action)
            @type = case action
            when "sale"
              :sale_request
            when "get_status"
              :status_request
            when "recurring_start"
              :recurring_start_request
            when "recurring_stop"
              :recurring_stop_request
            when "recurring_status"
              :recurring_status_request
            when "preauth"
              :preauth_request
            when "recurring_update"
              :recurring_update_request
            when "capture"
              :capture_request
            else
              raise ArgumentError, "Unknown action #{action}"
            end
          end
        end

      end
    end
  end
end
