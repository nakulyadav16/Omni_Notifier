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
                config.whatsapp_access_token,
                config.whatsapp_api_version
              )
              @messages_api = WhatsappSdk::Api::Messages.new(client)
            end

            def send_text(recipient:, message:)
              response = @messages_api.send_text(
                sender_id: sender_id,
                recipient_number: format_phone(recipient),
                message: message
              )
              parse_success(response)
            rescue StandardError => e
              handle_error(e)
            end

            def send_template(recipient:, template_name:, language: "en", components: [])
              response = @messages_api.send_template(
                sender_id: sender_id,
                recipient_number: format_phone(recipient),
                name: template_name,
                language: language,
                components: build_components(components)
              )
              parse_success(response)
            rescue StandardError => e
              handle_error(e)
            end

            private

            def sender_id
              @config.whatsapp_phone_number_id
            end

            def format_phone(num)
              s = num.to_s.delete(" ()-")
              s.start_with?("+") ? s : "+#{s}"
            end

            def build_components(components)
              return [] if components.nil? || components.empty?

              components.map do |component|
                case component[:type]
                when :header then build_header_component(component)
                when :body   then build_body_component(component)
                when :button then build_button_component(component)
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

            def parse_success(response)
              return error_result("Unknown error") unless response

              {
                success: true,
                message_id: response.messages&.first&.id,
                response: response
              }
            end

            def error_result(error, type: "Error", klass: nil)
              {
                success: false,
                error: error,
                error_type: type,
                error_class: klass
              }
            end

            def handle_error(error)
              case error
              when WhatsappSdk::Api::Responses::HttpResponseError
                error_result(error.message, type: "WhatsApp API Error", klass: error.class.name)
              else
                error_result(error.message, type: "Generic Error", klass: error.class.name)
                  .merge(backtrace: error.backtrace&.first(5))
              end
            end
          end
        end
      end
    end
  end
end
