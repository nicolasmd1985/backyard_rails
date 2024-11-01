require 'openai'

class ImageGenerationService
  def initialize
    @client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
  end

  def generate_design(description, photo_urls)
    # Limit the number of URLs for testing and debugging
    limited_photo_urls = photo_urls.take(1)
    combined_prompt = "Design a backyard using the photo as a reference: #{limited_photo_urls.join(', ')}. Include elements described: #{description}. Ensure the design matches the photo details and reflects these features accurately."

    Rails.logger.debug "Prompt being sent to OpenAI: #{combined_prompt}"

    begin
      response = @client.images.generate(
        parameters: {
          model: "dall-e-3",
          prompt: combined_prompt,
          n: 1,
          quality: "standard",
          size: "1024x1024"
        }
      )
      response['data'][0]['url']
    rescue Faraday::TimeoutError, Faraday::ServerError => e
      Rails.logger.error "Error generating image: #{e.message}"
      nil # Return nil or handle the error as needed
    rescue Faraday::BadRequestError => e
      Rails.logger.error "Bad request error: #{e.message}"
      nil # Log the specific bad request error
    end
  end
end
