# frozen_string_literal: true

require "omni_notifier/channels/email/providers/sendgrid_provider"

RSpec.describe OmniNotifier::Channels::Email::Providers::SendgridProvider do
  let(:config) { { sendgrid_api_key: "test_key" } }
  subject(:provider) { described_class.new(config) }

  describe "#initialize" do
    it "validates config on initialization" do
      expect { described_class.new({}) }
        .to raise_error(NameError)
    end

    it "accepts valid config" do
      expect(provider).to be_a(described_class)
    end
  end

  describe "#send_email" do
    let(:sg_api) { instance_double(SendGrid::API) }
    let(:client) { double("client") }
    let(:mail_endpoint) { double("mail") }
    let(:send_endpoint) { double("send") }

    before do
      allow(SendGrid::API).to receive(:new).and_return(sg_api)
      allow(sg_api).to receive(:client).and_return(client)
      allow(client).to receive(:mail).and_return(mail_endpoint)
      allow(mail_endpoint).to receive(:_).with("send").and_return(send_endpoint)
    end

    it "sends email successfully" do
      response = double(status_code: "202", headers: { "x-message-id" => "123" }, body: "")
      allow(send_endpoint).to receive(:post).and_return(response)

      result = provider.send_email(
        to: "test@example.com",
        subject: "Test",
        body: "Hello",
        from: "sender@example.com"
      )

      expect(result[:status_code]).to eq("202")
    end
  end
end
