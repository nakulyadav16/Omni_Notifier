# frozen_string_literal: true

module OmniNotifier
  class Configuration
    attr_accessor :whatsapp_access_token,
                  :whatsapp_phone_number_id,
                  :whatsapp_business_account_id,
                  :whatsapp_api_version,
                  :enabled_channels

    def initialize
      @whatsapp_access_token = nil
      @whatsapp_phone_number_id = nil
      @whatsapp_business_account_id = nil
      @whatsapp_api_version = "v17.0"
      @enabled_channels = []
    end

    def whatsapp_enabled?
      enabled_channels.include?(:whatsapp) &&
        whatsapp_configured?
    end

    def whatsapp_configured?
      !whatsapp_access_token.nil? &&
        !whatsapp_access_token.empty? &&
        !whatsapp_phone_number_id.nil? &&
        !whatsapp_phone_number_id.empty?
    end

    def validate!
      errors = []

      if enabled_channels.empty?
        errors << "At least one channel must be enabled. Use config.enabled_channels = [:whatsapp]"
      end

      if enabled_channels.include?(:whatsapp) && !whatsapp_configured?
        errors << "WhatsApp is enabled but not properly configured. Please set whatsapp_access_token and whatsapp_phone_number_id"
      end

      raise ConfigurationError, errors.join(", ") unless errors.empty?
    end
  end

  class ConfigurationError < StandardError; end
end
