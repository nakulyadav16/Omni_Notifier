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

      channels[channel_sym].send_notification(**params)
    end

    # def whatsapp
    #   get_channel(:whatsapp)
    # end

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
          # Future channels can be added here
          # when :email
          #   initialize_email if config.email_configured?
          # when :sms
          #   initialize_sms if config.sms_configured?
        end
      end
    end

    def initialize_whatsapp
      require_relative "channels/messaging/whatsapp/whatsapp_channel"
      @channels[:whatsapp] = Channels::Messaging::Whatsapp::WhatsappChannel.new(config)
    end

    def get_channel(channel_name)
      channel = channels[channel_name.to_sym]
      raise ChannelNotEnabledError, "Channel '#{channel_name}' is not enabled" unless channel

      channel
    end
  end

  class ChannelNotEnabledError < StandardError; end
end
