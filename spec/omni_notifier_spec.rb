# frozen_string_literal: true

RSpec.describe OmniNotifier do
  it "has a version number" do
    expect(OmniNotifier::VERSION).not_to be nil
  end

  describe ".configure" do
    after { OmniNotifier.reset_configuration! }

    it "yields configuration" do
      OmniNotifier.configure do |config|
        config.enabled_channels = [:email]
        config.sendgrid_api_key = "test"
      end
      expect(OmniNotifier.configuration.enabled_channels).to eq([:email])
    end
  end
end
