# frozen_string_literal: true

module OmniNotifier
  class Notifier
    attr_reader :channel_manager

    def initialize
      @channel_manager = ChannelManager.new(OmniNotifier.configuration)
    end

    # Send notification to a specific channel
    def send(channel:, **params)
      channel_manager.send(channel: channel, **params)
    end

    # Check available channels

    # Check if a channel is enabled
    def channel_enabled?(channel)
      channel_manager.channel_enabled?(channel)
    end
  end
end
