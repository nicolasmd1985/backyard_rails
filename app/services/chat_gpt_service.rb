require 'openai'
require 'json'

class ChatGptService
  def initialize
    @client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'], log_errors: true)
  end

  def generate_scenario(prompt)
    begin
      response = @client.chat(
        parameters: {
          model: "gpt-4",
          messages: [{ role: "user", content: prompt }],
          max_tokens: 700,
          temperature: 0.7
        }
      )

      # Extract content from the response
      content = response.dig("choices", 0, "message", "content").strip

      # Attempt to parse as JSON
      parse_scenario_content(content)
    rescue OpenAI::Error => e
      Rails.logger.error("Error generating scenario: #{e.message}")
      { "error" => "Could not parse response." }
    end
  end

  private

  def parse_scenario_content(content)
    JSON.parse(content)
  rescue JSON::ParserError => e
    Rails.logger.error("Error parsing scenario content: #{e.message}. Content: #{content}")
    { "error" => "Could not parse response. Please ensure ChatGPT is returning JSON format." }
  end
end
