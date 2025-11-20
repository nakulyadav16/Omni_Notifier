# frozen_string_literal: true

module OmniNotifier
  class ChannelManager
    attr_reader :config, :channels

    def initialize(config)
      @config = config
      @channels = {}
      initialize_channels
    end

    def send(channel:, **params)
      channel_sym = channel.to_sym

      unless channels.key?(channel_sym)
        raise ChannelNotEnabledError, "Channel '#{channel}' is not enabled or not supported"
      end

      channel_instance = channels[channel_sym]

      # Different channels have different method names
      case channel_sym
      when :whatsapp
        channel_instance.send_notification(**params)
      when :email, :sms, :telegram, :signal, :push, :voice, :in_app
        channel_instance.deliver(params)
      else
        raise ChannelNotEnabledError, "Unknown channel delivery method for '#{channel}'"
      end
    end

    def available_channels
      channels.keys
    end

    def channel_enabled?(channel)
      channels.key?(channel.to_sym)
    end

    private

    def initialize_channels
      config.enabled_channels.each do |channel|
        case channel.to_sym
        when :whatsapp
          initialize_whatsapp if config.whatsapp_configured?
        when :email
          initialize_email if config.email_configured?
        end
      end
    end

    def initialize_whatsapp
      require_relative "channels/messaging/whatsapp/whatsapp_channel"
      @channels[:whatsapp] = Channels::Messaging::Whatsapp::WhatsappChannel.new(config)
    end

    def initialize_email
      require_relative "channels/email/email_channel"
      @channels[:email] = Channels::Email::EmailChannel.new(config.to_h)
    end

    def get_channel(channel_name)
      channel = channels[channel_name.to_sym]
      raise ChannelNotEnabledError, "Channel '#{channel_name}' is not enabled" unless channel

      channel
    end
  end

  class ChannelNotEnabledError < StandardError; end
end
