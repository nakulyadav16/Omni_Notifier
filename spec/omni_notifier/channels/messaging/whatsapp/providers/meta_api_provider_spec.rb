# frozen_string_literal: true

require "omni_notifier/channels/messaging/whatsapp/providers/meta_api_provider"

RSpec.describe OmniNotifier::Channels::Messaging::Whatsapp::Providers::MetaApiProvider do
  let(:config) do
    {
      whatsapp_access_token: "test_token",
      whatsapp_phone_number_id: "123",
      whatsapp_api_version: "v17.0"
    }
  end

  subject(:provider) { described_class.new(config) }

  describe "#initialize" do
    it "creates WhatsApp SDK client" do
      expect(provider.client).to be_a(WhatsappSdk::Api::Client)
    end
  end

  describe "#send_text" do
    it "formats phone numbers" do
      expect(provider.send(:format_phone, "1234567890")).to eq("+1234567890")
      expect(provider.send(:format_phone, "+1234567890")).to eq("+1234567890")
    end
  end
end
