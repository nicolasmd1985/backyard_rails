# app/services/trefle_service.rb
require 'httparty'

class TrefleService
  include HTTParty
  base_uri 'https://trefle.io/api/v1'

  def initialize
    @api_key = ENV['TREFLE_API_KEY']
  end

  def fetch_plant_data(plant_name)
    response = self.class.get('/plants/search', query: { q: plant_name, token: @api_key })

    if response.success?
      plant_data = response.parsed_response['data']&.first # Get the first matching plant data
      if plant_data
        {
          name: plant_data['common_name'] || plant_name,
          description: plant_data['scientific_name'] || "No description available",
          image: plant_data['image_url'] || 'https://example.com/placeholder.jpg'
        }
      else
        { name: plant_name, description: "No data available", image: 'https://example.com/placeholder.jpg' }
      end
    else
      Rails.logger.error("Failed to fetch plant data for #{plant_name}: #{response.code} - #{response.body}")
      { name: plant_name, description: "No data available", image: 'https://example.com/placeholder.jpg' }
    end
  end
end
