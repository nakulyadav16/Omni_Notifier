# frozen_string_literal: true

require_relative "lib/omni_notifier/version"

Gem::Specification.new do |spec|
  spec.name = "omni_notifier"
  spec.version = OmniNotifier::VERSION
  spec.authors = ["Nakul Yadav"]
  spec.email = ["nakulyadav16@example.com"]

  spec.summary = "Multi-channel notification gem supporting Email, WhatsApp notifications"
  spec.description = "A comprehensive notification system supporting multiple channels (Email, WhatsApp with various providers (SendGrid, etc.)"
  spec.homepage = "https://github.com/nakulyadav16/Omni_Notifier"
  spec.required_ruby_version = ">= 2.6.0"
  spec.license = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/nakulyadav16/Omni_Notifier"
  # spec.metadata["changelog_uri"] = "https://github.com/nakulyadav16/Omni_Notifier/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "json", "~> 2.6"
  spec.add_dependency "sendgrid-ruby", "~> 6.0"
  spec.add_dependency "whatsapp_sdk"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
