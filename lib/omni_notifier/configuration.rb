# frozen_string_literal: true

module OmniNotifier
  class Configuration
    # WhatsApp configuration
    attr_accessor :whatsapp_access_token,
                  :whatsapp_phone_number_id,
                  :whatsapp_business_account_id,
                  :whatsapp_api_version,
                  :whatsapp_provider

    # Email configuration
    attr_accessor :email_provider,
                  :email_from,
                  :sendgrid_api_key

    attr_accessor :enabled_channels

    def initialize
      # WhatsApp defaults
      @whatsapp_access_token = nil
      @whatsapp_phone_number_id = nil
      @whatsapp_business_account_id = nil
      @whatsapp_api_version = "v17.0"
      @whatsapp_provider = :meta_api

      # Email defaults
      @email_provider = :sendgrid
      @email_from = nil
      @sendgrid_api_key = nil

      @enabled_channels = []
    end

    # Channel enabled checks
    def whatsapp_enabled?
      enabled_channels.include?(:whatsapp) && whatsapp_configured?
    end

    def email_enabled?
      enabled_channels.include?(:email) && email_configured?
    end

    def whatsapp_configured?
      !whatsapp_access_token.nil? &&
        !whatsapp_access_token.empty? &&
        !whatsapp_phone_number_id.nil? &&
        !whatsapp_phone_number_id.empty?
    end

    def email_configured?
      case email_provider.to_sym
      when :sendgrid
        !sendgrid_api_key.nil? && !sendgrid_api_key.empty?
      else
        false
      end
    end

    # Convert configuration to hash for channel providers
    def to_h
      {
        # WhatsApp
        whatsapp_access_token: whatsapp_access_token,
        whatsapp_phone_number_id: whatsapp_phone_number_id,
        whatsapp_business_account_id: whatsapp_business_account_id,
        whatsapp_api_version: whatsapp_api_version,
        whatsapp_provider: whatsapp_provider,
        # Email
        email_provider: email_provider,
        email_from: email_from,
        sendgrid_api_key: sendgrid_api_key
      }.compact
    end

    def validate!
      errors = []

      if enabled_channels.empty?
        errors << "At least one channel must be enabled. Use config.enabled_channels = [:email, :whatsapp, etc.]"
      end

      enabled_channels.each do |channel|
        case channel.to_sym
        when :whatsapp
          errors << "WhatsApp is enabled but not properly configured" unless whatsapp_configured?
        when :email
          errors << "Email is enabled but not properly configured" unless email_configured?
        end
      end

      raise ConfigurationError, errors.join(", ") unless errors.empty?
    end
  end
end
