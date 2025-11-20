# frozen_string_literal: true

require "sendgrid-ruby"

module OmniNotifier
  module Channels
    module Email
      module Providers
        class SendgridProvider
          include SendGrid

          def initialize(config = {})
            @config = config
            validate_config!
          end

          def send_email(to:, subject:, body:, from:, cc: nil, bcc: nil, attachments: nil)
            mail = build_mail(to, subject, body, from, cc, bcc, attachments)

            sg = SendGrid::API.new(api_key: @config[:api_key])
            response = sg.client.mail._("send").post(request_body: mail.to_json)

            handle_response(response)
          end

          private

          def build_mail(to, subject, body, from, cc, bcc, attachments)
            mail = SendGrid::Mail.new
            mail.from = SendGrid::Email.new(email: from)
            mail.subject = subject

            # Add personalization
            personalization = SendGrid::Personalization.new

            # Add recipients (to)
            Array(to).each do |recipient|
              personalization.add_to(SendGrid::Email.new(email: recipient))
            end

            # Add CC recipients
            if cc
              Array(cc).each do |recipient|
                personalization.add_cc(SendGrid::Email.new(email: recipient))
              end
            end

            # Add BCC recipients
            if bcc
              Array(bcc).each do |recipient|
                personalization.add_bcc(SendGrid::Email.new(email: recipient))
              end
            end

            mail.add_personalization(personalization)

            # Add content
            content = SendGrid::Content.new(type: "text/html", value: body)
            mail.add_content(content)

            # Add attachments
            if attachments
              Array(attachments).each do |attachment_path|
                add_attachment(mail, attachment_path)
              end
            end

            mail
          end

          def add_attachment(mail, attachment_path)
            attachment = SendGrid::Attachment.new
            attachment.content = Base64.strict_encode64(File.read(attachment_path))
            attachment.type = detect_mime_type(attachment_path)
            attachment.filename = File.basename(attachment_path)
            attachment.disposition = "attachment"

            mail.add_attachment(attachment)
          rescue StandardError => e
            raise ConfigurationError, "Error adding attachment #{attachment_path}: #{e.message}"
          end

          def detect_mime_type(file_path)
            case File.extname(file_path).downcase
            when ".pdf"
              "application/pdf"
            when ".jpg", ".jpeg"
              "image/jpeg"
            when ".png"
              "image/png"
            when ".gif"
              "image/gif"
            when ".txt"
              "text/plain"
            when ".csv"
              "text/csv"
            when ".zip"
              "application/zip"
            else
              "application/octet-stream"
            end
          end

          def handle_response(response)
            unless response.status_code.to_i.between?(200, 299)
              error_message = parse_error_response(response.body)
              raise DeliveryError, "SendGrid API error (#{response.status_code}): #{error_message}"
            end

            {
              status_code: response.status_code,
              message_id: response.headers["x-message-id"],
              body: response.body
            }
          end

          def parse_error_response(body)
            return body if body.nil? || body.empty?

            parsed = JSON.parse(body)
            errors = parsed.dig("errors")

            if errors && errors.is_a?(Array) && errors.any?
              errors.map { |err| err["message"] }.join(", ")
            else
              body
            end
          rescue JSON::ParserError
            body
          end

          def validate_config!
            raise ConfigurationError, "SendGrid API key is required" unless @config[:api_key]
          end
        end
      end
    end
  end
end
