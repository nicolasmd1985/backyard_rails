require 'openai'
require 'json'
require 'httparty'

class ChatGptService
  def initialize
    @client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'], log_errors: true)
  end

  def generate_scenario(prompt)
    begin
      # Adding instruction to prompt for JSON formatted response
      formatted_prompt = "#{prompt}\n\nPlease respond with a JSON array of objects, each containing the following keys: name, scientific_name, and description for each recommended plant."
      response = @client.chat(
        parameters: {
          model: "gpt-4",
          messages: [{ role: "user", content: formatted_prompt }],
          max_tokens: 700,
          temperature: 0.7
        }
      )
  
      # Extract content from the response
      content = response.dig("choices", 0, "message", "content").strip
  
      # Attempt to parse as JSON and fetch images
      plants = parse_scenario_content(content)
      plants.is_a?(Array) ? add_image_urls(plants) : plants # Ensure `plants` is an array before adding URLs
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
    formatted_name = plant_name.gsub(' ', '_').downcase # Format full name for initial search
    image_url = search_image(formatted_name)            # First attempt with full name
    
    # If no image found, try word-by-word search
    if image_url == "Image not found"
      plant_name.split.each do |word|
        image_url = search_image(word)                  # Attempt with individual word
        break if image_url != "Image not found"         # Stop if an image is found
      end
    end
  
    image_url # Return the found image URL or "Image not found"
  end
  
  private
  
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
