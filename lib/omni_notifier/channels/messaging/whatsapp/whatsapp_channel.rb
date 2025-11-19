# frozen_string_literal: true

require_relative "providers/meta_api_provider"

module OmniNotifier
  module Channels
    module Messaging
      module Whatsapp
        class WhatsappChannel < BaseMessengerChannel
          attr_reader :provider

          def initialize(config)
            super(config)
            @provider = initialize_provider
          end

          def send_notification(recipient:, message:, **options)
            validate_params!(recipient: recipient, message: message)

            case options[:type]
            when :template
              send_template_message(
                recipient: recipient,
                template_name: options[:template_name],
                language: options[:language] || "en",
                components: options[:components] || []
              )
            else
              send_text_message(recipient: recipient, message: message)
            end
          rescue StandardError => e
            handle_error(e, { recipient: recipient, type: options[:type] })
          end

          def send_text_message(recipient:, message:)
            validate_params!(recipient: recipient, message: message)

            result = provider.send_text(
              recipient: recipient,
              message: message
            )

            format_result(result)
          rescue StandardError => e
            handle_error(e, { recipient: recipient, message_type: :text })
          end

          def send_template_message(recipient:, template_name:, language: "en", components: [])
            validate_template_params!(
              recipient: recipient,
              template_name: template_name
            )

            result = provider.send_template(
              recipient: recipient,
              template_name: template_name,
              language: language,
              components: components
            )

            format_result(result)
          rescue StandardError => e
            handle_error(e, {
                           recipient: recipient,
                           message_type: :template,
                           template_name: template_name
                         })
          end

          def validate_params!(params)
            raise ArgumentError, "Recipient cannot be blank" if params[:recipient].to_s.strip.empty?
            raise ArgumentError, "Message cannot be blank" if params[:message].to_s.strip.empty?
          end

          def validate_template_params!(params)
            raise ArgumentError, "Recipient cannot be blank" if params[:recipient].to_s.strip.empty?
            raise ArgumentError, "Template name cannot be blank" if params[:template_name].to_s.strip.empty?
          end

          private

          def initialize_provider
            raise ConfigurationError, "WhatsApp is not properly configured" unless config.whatsapp_configured?

            Providers::MetaApiProvider.new(config)
          end

          def format_result(result)
            if result[:success]
              success_response(
                message_id: result[:message_id],
                channel: :whatsapp,
                provider: :meta_api
              )
            else
              {
                success: false,
                error: result[:error],
                error_code: result[:error_code],
                channel: :whatsapp,
                provider: :meta_api
              }
            end
          end
        end
      end
    end
  end
end
