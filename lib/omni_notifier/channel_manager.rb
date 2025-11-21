# frozen_string_literal: true

module OmniNotifier
  class ChannelManager
    class ChannelNotEnabledError < StandardError; end
    class ChannelNotSupportedError < StandardError; end

    attr_reader :config, :channels

    # CHANNEL REGISTRY:
    # Each entry defines: class_path, class_name
    CHANNEL_REGISTRY = {
      whatsapp: {
        file: "channels/messaging/whatsapp/whatsapp_channel",
        class: "Channels::Messaging::Whatsapp::WhatsappChannel",
      },
      email: {
        file: "channels/email/email_channel",
        class: "Channels::Email::EmailChannel",
      }
      # ➕ Add more channels here:
      # sms: { file: "...", class: "...", send_method: :deliver }
    }.freeze

    def initialize(config)
      @config = config
      @channels = {}
      initialize_enabled_channels
    end

    def send(channel:, **params)
      channel = channel.to_sym
      channel_instance = channels[channel]

      raise ChannelNotEnabledError, "Channel '#{channel}' is not enabled" unless channel_instance

      channel_instance.deliver(**params)
    end

    def channel_enabled?(channel)
      channels.key?(channel.to_sym)
    end

    private

    def initialize_enabled_channels
      config.enabled_channels.each do |channel|
        channel = channel.to_sym

        spec = CHANNEL_REGISTRY[channel]
        raise ChannelNotSupportedError, "Channel '#{channel}' is not supported" unless spec

        next unless config.channel_configured?(channel)

        channels[channel] = build_channel(spec)
      end
    end

    def build_channel(spec)
      require_relative spec[:file]
      klass = OmniNotifier.const_get(spec[:class])
      klass.new(config.to_h)
    end
  end
end
