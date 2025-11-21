# frozen_string_literal: true

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

          def deliver(recipient:, message:, **options)
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
            provider_name = config[:whatsapp_provider] || :meta_api

            case provider_name.to_sym
            when :meta_api
              require_relative "providers/meta_api_provider"
              Providers::MetaApiProvider.new(config)
            # when :gupshup
            #   require_relative "providers/gupshup_provider"
            #   Providers::GupshupProvider.new(config.to_h)
            else
              raise ConfigurationError, "Unknown WhatsApp provider: #{provider_name}"
            end
          end

          def format_result(result)
            provider_name = config[:whatsapp_provider] || :meta_api

            if result[:success]
              return success_response(
                message_id: result[:message_id],
                channel: :whatsapp,
                provider: provider_name
              )
            end

            {
              success: false,
              error: result[:error],
              error_code: result[:error_code],
              channel: :whatsapp,
              provider: provider_name
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
