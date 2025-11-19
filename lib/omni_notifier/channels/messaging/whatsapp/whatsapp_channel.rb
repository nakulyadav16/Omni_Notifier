# frozen_string_literal: true

require_relative "providers/meta_api_provider"

module OmniNotifier
  module Channels
    module Messaging
      module Whatsapp
        class WhatsappChannel < BaseMessengerChannel
          attr_reader :provider

          TEMPLATE_DEFAULT_LANGUAGE = "en"

          def initialize(config)
            super(config)
            @provider = initialize_provider
          end

          def send_notification(recipient:, message:, **options)
            if options[:type] == :template
              send_template_notification(recipient, options)
            else
              send_text_notification(recipient, message)
            end
          rescue StandardError => e
            handle_error(e, context_for(options, recipient))
          end

          private

          def send_text_notification(recipient, message)
            validate_presence!(recipient: recipient, message: message)

            format_result provider.send_text(
              recipient: recipient,
              message: message
            )
          end

          def send_template_notification(recipient, options)
            validate_presence!(
              recipient: recipient,
              template_name: options[:template_name]
            )

            format_result provider.send_template(
              recipient: recipient,
              template_name: options[:template_name],
              language: options[:language] || TEMPLATE_DEFAULT_LANGUAGE,
              components: options[:components] || []
            )
          end

          def validate_presence!(fields)
            fields.each do |key, value|
              raise ArgumentError, "#{key.to_s.capitalize} cannot be blank" if value.to_s.strip.empty?
            end
          end

          def initialize_provider
            raise ConfigurationError, "WhatsApp is not properly configured" unless config.whatsapp_configured?

            Providers::MetaApiProvider.new(config)
          end

          def format_result(result)
            if result[:success]
              return success_response(
                message_id: result[:message_id],
                channel: :whatsapp,
                provider: :meta_api
              )
            end

            {
              success: false,
              error: result[:error],
              error_code: result[:error_code],
              channel: :whatsapp,
              provider: :meta_api
            }
          end

          def context_for(options, recipient)
            {
              recipient: recipient,
              message_type: options[:type],
              template_name: options[:template_name]
            }.compact
          end
        end
      end
    end
  end
end
