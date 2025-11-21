# frozen_string_literal: true

RSpec.describe OmniNotifier::ChannelManager do
  let(:config) do
    OmniNotifier::Configuration.new.tap do |c|
      c.enabled_channels = [:whatsapp]
      c.whatsapp_access_token = "test_token"
      c.whatsapp_phone_number_id = "123"
    end
  end

  subject(:manager) { described_class.new(config) }

  describe "#initialize" do
    it "initializes with configuration" do
      expect(manager.config).to eq(config)
    end
  end

  describe "#channel_enabled?" do
    it "returns true for enabled channel" do
      expect(manager.channel_enabled?(:whatsapp)).to be true
    end

    it "returns false for disabled channel" do
      expect(manager.channel_enabled?(:email)).to be false
    end
  end

  describe "#send" do
    it "raises error when channel is not enabled" do
      expect { manager.send(channel: :email, recipient: "test", message: "test") }
        .to raise_error(OmniNotifier::ChannelManager::ChannelNotEnabledError)
    end
  end
end
