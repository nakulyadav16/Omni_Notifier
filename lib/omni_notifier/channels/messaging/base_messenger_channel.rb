# frozen_string_literal: true

module OmniNotifier
  module Channels
    module Messaging
      class BaseMessengerChannel < BaseChannel
        def send_text_message(recipient:, message:)
          raise NotImplementedError, "#{self.class} must implement #send_text_message"
        end

        def send_template_message(recipient:, template_name:, **params)
          raise NotImplementedError, "#{self.class} must implement #send_template_message"
        end
      end
    end
  end
end
