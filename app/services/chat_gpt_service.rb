require 'openai'
require 'json'
require 'httparty'

class ChatGptService
  def initialize
    @client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'], log_errors: true)
  end

  def generate_scenario(prompt)
    begin
      # Add clear instructions for a short, cost-effective response
      # formatted_prompt = <<~PROMPT
      #   #{prompt}

      #   Please respond with a JSON array of exactly 5 objects. 
      #   Each object should contain: 
      #   - name: The common name of the recommended plant (short string)
      #   - scientific_name: The scientific name (short string)
      #   - description: A brief, one to two sentence description 
      #     of why this plant is suitable.

      #   Keep responses concise and do not include extra text outside of the JSON array.
      # PROMPT
      
      formatted_prompt = <<~PROMPT
        #{prompt}

        Please respond with a JSON array of max 10 objects. 
        Each object should contain: 
        - name: The common name of the recommended plant (short string)
        - scientific_name: The scientific name (short string)
        - description: A brief, one to two sentence description 
          of why this plant is suitable.

        Keep responses concise and do not include extra text outside of the JSON array.
      PROMPT

      response = @client.chat(
        parameters: {
          # Use a cheaper model like gpt-3.5-turbo instead of gpt-4
          model: "gpt-3.5-turbo",
          messages: [{ role: "user", content: formatted_prompt }],
          max_tokens: 2000,   # Reduced max tokens to lower cost
          temperature: 0.7
        }
      )

      content = response.dig("choices", 0, "message", "content")&.strip
      plants = parse_scenario_content(content)
      plants.is_a?(Array) ? add_image_urls(plants) : plants
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
    { "error" => "Could not parse response. Expected JSON format.", "content" => content }
  end

  def add_image_urls(plants)
    plants.each do |plant|
      plant['image_url'] = fetch_plant_image(plant['name'])
    end
    plants
  end

  def fetch_plant_image(plant_name)
    formatted_name = plant_name.gsub(' ', '_').downcase 
    image_url = search_image(formatted_name)

    if image_url == "Image not found"
      plant_name.split.each do |word|
        image_url = search_image(word)
        break if image_url != "Image not found"
      end
    end

    image_url
  end

  def search_image(query)
    response = HTTParty.get("https://en.wikipedia.org/w/api.php", query: {
      action: "query",
      titles: query,
      prop: "pageimages",
      format: "json",
      pithumbsize: 500
    })

    page = response.dig("query", "pages").values.first
    page&.dig("thumbnail", "source") || "Image not found"
  end
end
