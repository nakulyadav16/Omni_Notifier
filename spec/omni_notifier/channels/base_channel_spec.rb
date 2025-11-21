# frozen_string_literal: true

RSpec.describe OmniNotifier::Channels::BaseChannel do
  let(:config) { { test: "config" } }
  subject(:channel) { described_class.new(config) }

  describe "#initialize" do
    it "stores config" do
      expect(channel.config).to eq(config)
    end
  end

  describe "#deliver" do
    it "raises NotImplementedError" do
      expect { channel.deliver(recipient: "test", message: "test") }
        .to raise_error(NotImplementedError)
    end
  end

  describe "#validate_params!" do
    it "raises NotImplementedError" do
      expect { channel.validate_params!({}) }
        .to raise_error(NotImplementedError)
    end
  end

  describe "#success_response" do
    it "returns success hash" do
      result = channel.send(:success_response, { data: "test" })
      expect(result[:success]).to be true
      expect(result[:data][:data]).to eq("test")
    end
  end

  describe "#handle_error" do
    it "returns error hash" do
      error = StandardError.new("test error")
      result = channel.send(:handle_error, error)
      expect(result[:success]).to be false
      expect(result[:error]).to eq("test error")
    end
  end
end
