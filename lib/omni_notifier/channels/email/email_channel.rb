# frozen_string_literal: true

module OmniNotifier
  module Channels
    module Email
      class EmailChannel < BaseChannel
        PROVIDER_REGISTRY = {
          sendgrid: {
            file: "providers/sendgrid_provider",
            class: "OmniNotifier::Channels::Email::Providers::SendgridProvider"
          }
          # ➕ Add new providers here easily
          # postmark: { file: "providers/postmark_provider", class: "..." }
          # ses:      { file: "providers/ses_provider", class: "..." }
        }.freeze

        REQUIRED_FIELDS = %i[to subject body].freeze

        def initialize(config = {})
          super
          @provider = build_provider
        end

        def deliver(message)
          validate_message!(message)
          @provider.send_email(
            to:          message[:to],
            subject:     message[:subject],
            body:        message[:body],
            from:        message[:from] || @config[:from],
            cc:          message[:cc],
            bcc:         message[:bcc],
            attachments: message[:attachments]
          )
        end

        private

        def build_provider
          provider_name = (@config[:email_provider] || :sendgrid).to_sym
          spec = PROVIDER_REGISTRY[provider_name]

          raise ConfigurationError, "Unknown email provider: #{provider_name}" unless spec

          require_relative spec[:file]
          provider_class = OmniNotifier.const_get(spec[:class])
          provider_class.new(@config)
        end

        def validate_message!(message)
          missing = REQUIRED_FIELDS.select { |f| message[f].nil? || message[f].to_s.empty? }
          return if missing.empty?

          raise ArgumentError, "Missing required email fields: #{missing.join(', ')}"
        end
      end
    end
  end
end
