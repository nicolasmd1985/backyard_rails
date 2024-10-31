require 'openai'

class ChatGptService
  def initialize
    @client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'], log_errors: true)
  end

  def generate_scenario(prompt)
    response = @client.chat(
      parameters: {
        model: "gpt-4", # or "gpt-3.5-turbo" if needed
        messages: [{ role: "user", content: prompt }],
        max_tokens: 200,
        temperature: 0.7
      }
    )
    response.dig("choices", 0, "message", "content").strip
  end
end
