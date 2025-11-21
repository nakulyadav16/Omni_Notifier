# frozen_string_literal: true

RSpec.describe OmniNotifier::Notifier do
  subject(:notifier) { described_class.new }

  before do
    OmniNotifier.configure do |config|
      config.enabled_channels = [:whatsapp]
      config.whatsapp_access_token = "test_token"
      config.whatsapp_phone_number_id = "123"
    end
  end

  after do
    OmniNotifier.reset_configuration!
  end

  describe "#initialize" do
    it "creates a channel manager" do
      expect(notifier.channel_manager).to be_a(OmniNotifier::ChannelManager)
    end
  end

  describe "#channel_enabled?" do
    it "checks if channel is enabled" do
      expect(notifier.channel_enabled?(:whatsapp)).to be true
      expect(notifier.channel_enabled?(:email)).to be false
    end
  end
end
