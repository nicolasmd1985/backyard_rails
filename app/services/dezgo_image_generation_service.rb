require 'httparty'
require 'base64'
require 'aws-sdk-s3'

class DezgoImageGenerationService
  API_ENDPOINT = "https://api.dezgo.com/image2image"

  def initialize
    @api_key = ENV['DEZGO_API_KEY']
    @s3_service = S3UploadService.new
  end

  def generate_design(description, photo_urls)
    # Limit the number of URLs for testing and debugging
    limited_photo_urls = photo_urls.take(1)

    # Encode the first image to Base64
    encoded_image = encode_image_to_base64(limited_photo_urls.first)
    return nil unless encoded_image

    # Prepare the payload
    payload = {
      prompt: description,
      negative_prompt: "house, building, structure, window, door, roof, man-made exterior walls, people",
      init_image: encoded_image,
      strength: 0.8, # Adjust based on the desired transformation level
      steps: 30,     # Number of inference steps
      guidance: 10, # Adjust prompt adherence
      size: "512x512"
    }

    # Rails.logger.debug "Payload being sent to Dezgo: #{payload}"

    begin
      response = HTTParty.post(
        API_ENDPOINT,
        headers: {
          'X-Dezgo-Key' => @api_key,
          'Content-Type' => 'application/json'
        },
        body: payload.to_json
      )

      if response.success?
        Rails.logger.info "Image successfully generated."
        file_path = save_image_to_temp_file(response.body)
        s3_url = upload_to_s3(file_path)
        File.delete(file_path) if File.exist?(file_path)
        return s3_url
      else
        Rails.logger.error "Error from Dezgo API: #{response.body}"
        nil
      end
    rescue StandardError => e
      Rails.logger.error "Error generating image: #{e.message}"
      nil
    end
  end

  private

  def encode_image_to_base64(image_url)
    begin
      response = HTTParty.get(image_url)
      if response.success?
        Base64.strict_encode64(response.body)
      else
        Rails.logger.error "Failed to fetch image from URL: #{image_url}"
        nil
      end
    rescue StandardError => e
      Rails.logger.error "Error encoding image to Base64: #{e.message}"
      nil
    end
  end

  def save_image_to_temp_file(image_data)
    file_path = "tmp/generated_image_#{Time.now.to_i}.jpg"
    File.open(file_path, "wb") do |file|
      file.write(image_data)
    end
    file_path
  end

  def upload_to_s3(file_path)
    key = "generated_images/#{File.basename(file_path)}"
    @s3_service.upload(File.open(file_path), key)
  end
end