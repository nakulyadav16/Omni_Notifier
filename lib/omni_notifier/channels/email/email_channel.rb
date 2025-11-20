# frozen_string_literal: true

module OmniNotifier
  module Channels
    module Email
      class EmailChannel < BaseChannel
        def initialize(config = {})
          super
          @provider = setup_provider
        end

        def deliver(message)
          validate_message!(message)
          @provider.send_email(
            to: message[:to],
            subject: message[:subject],
            body: message[:body],
            from: message[:from] || @config[:from],
            cc: message[:cc],
            bcc: message[:bcc],
            attachments: message[:attachments]
          )
        end

        private

        def setup_provider
          provider_name = @config[:provider] || :smtp
          provider_class = case provider_name.to_sym
                           when :smtp
                             require_relative "providers/smtp_provider"
                             Providers::SmtpProvider
                           when :sendgrid
                             require_relative "providers/sendgrid_provider"
                             Providers::SendgridProvider
                           when :mailgun
                             require_relative "providers/mailgun_provider"
                             Providers::MailgunProvider
                           else
                             raise ConfigurationError, "Unknown email provider: #{provider_name}"
                           end
          provider_class.new(@config)
        end

        def validate_message!(message)
          raise ArgumentError, "Recipient email is required" unless message[:to]
          raise ArgumentError, "Subject is required" unless message[:subject]
          raise ArgumentError, "Body is required" unless message[:body]
        end
      end
    end
  end
end
