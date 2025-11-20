# frozen_string_literal: true

module OmniNotifier
  module Templates
    class Formatter
      def initialize(template, variables = {})
        @template = template
        @variables = variables
      end

      def format
        result = @template.dup
        @variables.each do |key, value|
          result.gsub!("{{#{key}}}", value.to_s)
          result.gsub!("{{ #{key} }}", value.to_s)
        end
        result
      end

      def self.format(template, variables = {})
        new(template, variables).format
      end

      # Support for different template types
      def format_html
        format
      end

      def format_text
        strip_html(format)
      end

      def format_markdown
        format
      end

      private

      def strip_html(text)
        text.gsub(/<[^>]*>/, "")
            .gsub(/&nbsp;/, " ")
            .gsub(/&amp;/, "&")
            .gsub(/&lt;/, "<")
            .gsub(/&gt;/, ">")
            .gsub(/&quot;/, '"')
            .strip
      end
    end
  end
end
