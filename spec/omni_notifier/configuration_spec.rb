# frozen_string_literal: true

RSpec.describe OmniNotifier::Configuration do
  subject(:config) { described_class.new }

  describe "#initialize" do
    it "sets default values" do
      expect(config.whatsapp_api_version).to eq("v17.0")
      expect(config.whatsapp_provider).to eq(:meta_api)
      expect(config.email_provider).to eq(:sendgrid)
      expect(config.enabled_channels).to eq([])
    end
  end

  describe "#channel_enabled?" do
    it "returns true when channel is enabled" do
      config.enabled_channels = [:email]
      expect(config.channel_enabled?(:email)).to be true
    end

    it "returns false when channel is not enabled" do
      expect(config.channel_enabled?(:email)).to be false
    end
  end

  describe "#validate!" do
    it "raises error when no channels are enabled" do
      expect { config.validate! }.to raise_error(OmniNotifier::Configuration::ConfigurationError)
    end

    it "raises error when enabled channel is not configured" do
      config.enabled_channels = [:whatsapp]
      expect { config.validate! }.to raise_error(OmniNotifier::Configuration::ConfigurationError)
    end

    it "passes when channel is properly configured" do
      config.enabled_channels = [:whatsapp]
      config.whatsapp_access_token = "token"
      config.whatsapp_phone_number_id = "123"
      expect { config.validate! }.not_to raise_error
    end
  end

  describe "#to_h" do
    it "returns configuration as hash" do
      result = config.to_h
      expect(result).to be_a(Hash)
      expect(result[:enabled_channels]).to eq([])
    end
  end
end
