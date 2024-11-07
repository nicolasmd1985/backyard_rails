# app/services/wikipedia_service.rb
require 'httparty'
require 'cgi'

class WikipediaService
  include HTTParty
  base_uri 'https://en.wikipedia.org/api/rest_v1'

  def initialize
    # No API key required for Wikipedia
  end

  def fetch_plant_data(plant_name)
    encoded_name = URI.encode_www_form_component(plant_name).gsub('+', '%20')
    response = self.class.get("/page/summary/#{encoded_name}")

    if response.success?
      plant_data = response.parsed_response
      {
        name: plant_name,
        description: plant_data['extract'] || "No description available",
        image: plant_data.dig('thumbnail', 'source') || 'https://example.com/placeholder.jpg'
      }
    else
      Rails.logger.error("Failed to fetch plant data for #{plant_name}: #{response.code} - #{response.body}")
      { name: plant_name, description: "No data available", image: 'https://example.com/placeholder.jpg' }
    end
  end
end
