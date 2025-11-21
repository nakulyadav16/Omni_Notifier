# frozen_string_literal: true

require "omni_notifier/channels/email/email_channel"

RSpec.describe OmniNotifier::Channels::Email::EmailChannel do
  let(:config) do
    {
      email_provider: :sendgrid,
      sendgrid_api_key: "test_key",
      from: "sender@example.com"
    }
  end

  subject(:channel) { described_class.new(config) }

  describe "#deliver" do
    it "raises error when required fields are missing" do
      message = { to: "test@example.com" }
      expect { channel.deliver(message) }
        .to raise_error(ArgumentError, /Missing required email fields/)
    end

    it "validates all required fields" do
      message = { to: "", subject: "", body: "" }
      expect { channel.deliver(message) }
        .to raise_error(ArgumentError, /Missing required email fields/)
    end
  end
end
