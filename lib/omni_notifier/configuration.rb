# frozen_string_literal: true

module OmniNotifier
  class Configuration
    class ConfigurationError < StandardError; end

    # Registry for supported channels and their configuration requirements
    CHANNELS = {
      whatsapp: {
        required: %i[whatsapp_access_token whatsapp_phone_number_id],
        provider_key: :whatsapp_provider
      },
      email: {
        required: %i[],
        provider_key: :email_provider
      }
    }.freeze

    # Registry for providers and their required fields
    PROVIDERS = {
      sendgrid: {
        for: :email,
        required: %i[sendgrid_api_key]
      },
      meta_api: {
        for: :whatsapp,
        required: %i[whatsapp_access_token whatsapp_phone_number_id]
      }
      # ➕ Add more providers here without touching other logic
    }.freeze

    attr_accessor :enabled_channels

    # WhatsApp config
    attr_accessor :whatsapp_access_token,
                  :whatsapp_phone_number_id,
                  :whatsapp_business_account_id,
                  :whatsapp_api_version,
                  :whatsapp_provider

    # Email config
    attr_accessor :email_provider,
                  :sendgrid_api_key

    def initialize
      # default values
      @whatsapp_api_version = "v17.0"
      @whatsapp_provider     = :meta_api
      @email_provider        = :sendgrid

      @enabled_channels = []
    end

    def channel_enabled?(channel)
      enabled_channels.include?(channel.to_sym)
    end

    def channel_configured?(channel)
      config = CHANNELS[channel.to_sym]
      return false unless config

      # Check required fields
      config[:required].all? { |field| present? public_send(field) } &&
        provider_configured?(provider_for(channel))
    end

    def provider_for(channel)
      key = CHANNELS[channel.to_sym][:provider_key]
      public_send(key)
    end

    def provider_configured?(provider)
      spec = PROVIDERS[provider.to_sym]
      return false unless spec

      spec[:required].all? { |field| present? public_send(field) }
    end

    def validate!
      errors = []

      if enabled_channels.empty?
        errors << "At least one channel must be enabled. Use config.enabled_channels = [:email, :whatsapp]"
      end

      enabled_channels.each do |channel|
        unless channel_configured?(channel)
          errors << "#{channel.capitalize} is enabled but not properly configured"
        end
      end

      raise ConfigurationError, errors.join(", ") unless errors.empty?
    end

    def to_h
      instance_variables.each_with_object({}) do |var, hash|
        key = var.to_s.delete("@").to_sym
        value = instance_variable_get(var)
        hash[key] = value unless value.nil?
      end
    end

    private

    def present?(value)
      !(value.nil? || (value.respond_to?(:empty?) && value.empty?))
    end
  end
end
