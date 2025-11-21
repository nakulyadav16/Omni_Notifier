# frozen_string_literal: true

require "omni_notifier/channels/messaging/whatsapp/whatsapp_channel"

RSpec.describe OmniNotifier::Channels::Messaging::Whatsapp::WhatsappChannel do
  let(:config) do
    {
      whatsapp_access_token: "test_token",
      whatsapp_phone_number_id: "123",
      whatsapp_api_version: "v17.0",
      whatsapp_provider: :meta_api
    }
  end

  subject(:channel) { described_class.new(config) }

  describe "#initialize" do
    it "initializes with provider" do
      expect(channel.provider).to be_a(OmniNotifier::Channels::Messaging::Whatsapp::Providers::MetaApiProvider)
    end
  end

  describe "#deliver" do
    let(:provider) { instance_double(OmniNotifier::Channels::Messaging::Whatsapp::Providers::MetaApiProvider) }

    before do
      allow(channel).to receive(:provider).and_return(provider)
    end

    context "with text message" do
      it "sends text message" do
        allow(provider).to receive(:send_text).and_return({ success: true, message_id: "123" })
        result = channel.deliver(recipient: "+1234567890", message: "Hello")
        expect(result[:success]).to be true
      end

      it "validates recipient presence" do
        result = channel.deliver(recipient: "", message: "Hello")
        expect(result[:success]).to be false
      end
    end

    context "with template message" do
      it "sends template message" do
        allow(provider).to receive(:send_template).and_return({ success: true, message_id: "123" })
        result = channel.deliver(
          recipient: "+1234567890",
          message: "",
          type: :template,
          template_name: "test_template"
        )
        expect(result[:success]).to be true
      end
    end
  end
end
