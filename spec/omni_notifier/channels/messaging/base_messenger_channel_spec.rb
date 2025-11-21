# frozen_string_literal: true

RSpec.describe OmniNotifier::Channels::Messaging::BaseMessengerChannel do
  let(:config) { { test: "config" } }
  subject(:channel) { described_class.new(config) }

  describe "#send_text_message" do
    it "raises NotImplementedError" do
      expect { channel.send_text_message(recipient: "test", message: "test") }
        .to raise_error(NotImplementedError)
    end
  end

  describe "#send_template_message" do
    it "raises NotImplementedError" do
      expect { channel.send_template_message(recipient: "test", template_name: "test") }
        .to raise_error(NotImplementedError)
    end
  end
end
