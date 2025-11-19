# frozen_string_literal: true

require "whatsapp_sdk"

module OmniNotifier
  module Channels
    module Messaging
      module Whatsapp
        module Providers
          class MetaApiProvider
            attr_reader :client

            def initialize(config)
              @config = config
              @client = WhatsappSdk::Api::Client.new(
                @config.whatsapp_access_token,
                @config.whatsapp_api_version
              )
              @messages_api = WhatsappSdk::Api::Messages.new(@client)
            end

            def send_text(recipient:, message:)
              response = @messages_api.send_text(
                sender_id: @config.whatsapp_phone_number_id,
                recipient_number: format_phone_number(recipient),
                message: message
              )

              parse_response(response)
            rescue WhatsappSdk::Api::Responses::HttpResponseError => e
              handle_whatsapp_error(e)
            rescue StandardError => e
              handle_generic_error(e)
            end

            def send_template(recipient:, template_name:, language: "en", components: [])
              template_components = build_template_components(components)

              response = @messages_api.send_template(
                sender_id: @config.whatsapp_phone_number_id,
                recipient_number: format_phone_number(recipient),
                name: template_name,
                language: language,
                components: template_components
              )

              parse_response(response)
            rescue WhatsappSdk::Api::Responses::HttpResponseError => e
              handle_whatsapp_error(e)
            rescue StandardError => e
              handle_generic_error(e)
            end
            private

            def format_phone_number(number)
              # Remove any spaces, dashes, or parentheses
              cleaned = number.to_s.gsub(/[\s\-()]/, "")

              # Add + if not present
              cleaned.start_with?("+") ? cleaned : "+#{cleaned}"
            end

            def build_template_components(components)
              return [] if components.empty?

              components.map do |component|
                case component[:type]
                when :header
                  build_header_component(component)
                when :body
                  build_body_component(component)
                when :button
                  build_button_component(component)
                else
                  component
                end
              end
            end

            def build_header_component(component)
              WhatsappSdk::Resource::Component.new(
                type: WhatsappSdk::Resource::Component::Type::HEADER,
                parameters: component[:parameters] || []
              )
            end

            def build_body_component(component)
              parameters = (component[:parameters] || []).map do |param|
                WhatsappSdk::Resource::ParameterObject.new(
                  type: WhatsappSdk::Resource::ParameterObject::Type::TEXT,
                  text: param
                )
              end

              WhatsappSdk::Resource::Component.new(
                type: WhatsappSdk::Resource::Component::Type::BODY,
                parameters: parameters
              )
            end

            def build_button_component(component)
              WhatsappSdk::Resource::Component.new(
                type: WhatsappSdk::Resource::Component::Type::BUTTON,
                sub_type: component[:sub_type],
                index: component[:index],
                parameters: component[:parameters] || []
              )
            end

            def parse_response(response)
              if response
                {
                  success: true,
                  message_id: response.messages&.first&.id,
                  response: response
                }
              else
                {
                  success: false,
                  error: response.error&.message || "Unknown error",
                  error_code: response.error&.code,
                  error_data: response.error
                }
              end
            end

            def handle_whatsapp_error(error)
              {
                success: false,
                error: error.message,
                error_type: "WhatsApp API Error",
                error_class: error.class.name
              }
            end

            def handle_generic_error(error)
              {
                success: false,
                error: error.message,
                error_type: "Generic Error",
                error_class: error.class.name,
                backtrace: error.backtrace&.first(5)
              }
            end
          end
        end
      end
    end
  end
end
