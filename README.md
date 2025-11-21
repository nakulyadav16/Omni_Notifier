# OmniNotifier

A comprehensive multi-channel notification system for Ruby applications. Send notifications through Email, WhatsApp, and more with a unified, extensible interface.

## Features

- **Multi-channel support**: Email, WhatsApp, and easily extensible for more channels
- **Multiple providers**: SendGrid for email, Meta API for WhatsApp
- **Flexible configuration**: Configure channels and providers independently
- **Type-safe messaging**: Template-based and text notifications for messaging channels
- **Easy to extend**: Add new channels and providers with minimal code changes

## Requirements

- Ruby >= 2.6.0
- Bundler

### Dependencies

- `json` (~> 2.6)
- `sendgrid-ruby` (~> 6.0) - for email notifications
- `whatsapp_sdk` - for WhatsApp notifications

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/nakulyadav16/Omni_Notifier.git
cd omni_notifier
```

### 2. Install Dependencies

```bash
bundle install
```

### 3. Run Tests

```bash
bundle exec rspec
```

Or simply:

```bash
rake spec
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'omni_notifier'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install omni_notifier
```

## Usage

### Configuration

Configure OmniNotifier with your channel credentials:

```ruby
require 'omni_notifier'

OmniNotifier.configure do |config|
  # Enable the channels you want to use
  config.enabled_channels = [:email, :whatsapp]

  # Email configuration (SendGrid)
  config.email_provider = :sendgrid
  config.sendgrid_api_key = 'your_sendgrid_api_key'

  # WhatsApp configuration (Meta API)
  config.whatsapp_provider = :meta_api
  config.whatsapp_access_token = 'your_whatsapp_access_token'
  config.whatsapp_phone_number_id = 'your_phone_number_id'
  config.whatsapp_business_account_id = 'your_business_account_id' # optional
  config.whatsapp_api_version = 'v17.0' # optional, defaults to v17.0
end
```

### Sending Email Notifications

```ruby
# Using the convenience method
OmniNotifier.notify(
  channel: :email,
  to: 'recipient@example.com',
  subject: 'Hello from OmniNotifier',
  body: 'This is a test email notification.',
  from: 'sender@example.com'
)

# With additional options
OmniNotifier.notify(
  channel: :email,
  to: 'recipient@example.com',
  subject: 'Important Update',
  body: 'Email body content here',
  cc: 'cc@example.com',
  bcc: 'bcc@example.com',
  attachments: []
)
```

### Sending WhatsApp Notifications

#### Text Messages

```ruby
OmniNotifier.notify(
  channel: :whatsapp,
  recipient: '1234567890',
  message: 'Hello from OmniNotifier!'
)
```

#### Template Messages

```ruby
OmniNotifier.notify(
  channel: :whatsapp,
  recipient: '1234567890',
  message: "",
  type: :template,
  template_name: 'welcome_message',
  language: 'en',
  components: [
    {
      type: 'body',
      parameters: [
        { type: 'text', text: 'John Doe' }
      ]
    }
  ]
)
```

### Channel Management

```ruby
# Get all enabled channels
enabled = OmniNotifier.notifier.enabled_channels
# => [:email, :whatsapp]

# Get available channels (all registered channels)
available = OmniNotifier.notifier.available_channels
# => [:email, :whatsapp]
```

### Error Handling

```ruby
begin
  OmniNotifier.notify(
    channel: :email,
    to: 'user@example.com',
    subject: 'Test',
    body: 'Message'
  )
rescue OmniNotifier::Configuration::ConfigurationError => e
  puts "Configuration error: #{e.message}"
rescue ArgumentError => e
  puts "Invalid parameters: #{e.message}"
rescue StandardError => e
  puts "Unexpected error: #{e.message}"
end
```

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake spec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Extending OmniNotifier

### Adding a New Channel

1. Create a new channel class inheriting from `BaseChannel`
2. Implement the `deliver` method
3. Register the channel in the configuration

### Adding a New Provider

1. Create a provider class in the appropriate channel directory
2. Implement the required methods for your provider
3. Register the provider in the channel's `PROVIDER_REGISTRY`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nakulyadav16/Omni_Notifier.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
