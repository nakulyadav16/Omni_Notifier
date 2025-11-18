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

    # Convenience method for WhatsApp
    def send_whatsapp(recipient:, message:, **options)
      send(channel: :whatsapp, recipient: recipient, message: message, **options)
    end

    # Send to multiple channels
    def broadcast(channels:, **params)
      results = {}

      channels.each do |channel|
        results[channel] = begin
          send(channel: channel, **params)
        rescue StandardError => e
          {
            success: false,
            error: e.message,
            error_class: e.class.name
          }
        end
      end

      {
        success: results.values.all? { |r| r[:success] },
        results: results
      }
    end

    # Get specific channel for advanced usage
    def whatsapp
      channel_manager.whatsapp
    end

    # Check available channels
    def available_channels
      channel_manager.available_channels
    end

    # Check if a channel is enabled
    def channel_enabled?(channel)
      channel_manager.channel_enabled?(channel)
    end
  end
end