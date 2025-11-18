# frozen_string_literal: true

require_relative "omni_notifier/version"
require_relative "omni_notifier/configuration"
require_relative "omni_notifier/channels/base_channel"
require_relative "omni_notifier/channels/messaging/base_messenger_channel"
require_relative "omni_notifier/channel_manager"
require_relative "omni_notifier/notifier"

module OmniNotifier
  class Error < StandardError; end

  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
      configuration.validate!
    end

    def reset_configuration!
      @configuration = Configuration.new
    end

    # Convenience method to send notifications
    def notify(channel:, **params)
      notifier.send(channel: channel, **params)
    end

    # Get notifier instance
    def notifier
      @notifier ||= Notifier.new
    end

    # Reset notifier (useful after configuration changes)
    def reset_notifier!
      @notifier = nil
    end
  end
end