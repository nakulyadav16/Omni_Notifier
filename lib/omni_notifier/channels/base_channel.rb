# frozen_string_literal: true

module OmniNotifier
  module Channels
    class BaseChannel
      attr_reader :config

      def initialize(config)
        @config = config
      end

      def send_notification(recipient:, message:, **options)
        raise NotImplementedError, "#{self.class} must implement #send_notification"
      end

      def validate_params!(params)
        raise NotImplementedError, "#{self.class} must implement #validate_params!"
      end

      protected

      def handle_error(error, context = {})
        {
          success: false,
          error: error.message,
          error_class: error.class.name,
          context: context
        }
      end

      def success_response(data = {})
        {
          success: true,
          data: data
        }
      end
    end
  end
end
