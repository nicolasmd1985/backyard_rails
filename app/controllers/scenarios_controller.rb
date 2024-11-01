class ScenariosController < ApplicationController
  def generate
    service = ChatGptService.new
    location = params[:location]
    scenario_type = params[:scenario_type]
    photos = params[:photos] # Array of S3 URLs

    # Use the appropriate method to generate the response
    scenario_text = case scenario_type
    when 'foodGarden'
      service.generate_scenario("Suggest food-producing plants for a backyard in #{location}.")
    when 'ecoFriendly'
      service.generate_scenario("Suggest native, eco-friendly plants for a sustainable backyard in #{location}.")
    when 'mixed'
      service.generate_scenario("Combine food-producing and eco-friendly plants for a backyard in #{location}.")
    else
      "Invalid scenario type selected."
    end

    # Integrate with ImageGenerationService and pass the photo URLs
    design_image_url = ImageGenerationService.new.generate_design(scenario_text, photos)

    render json: {
      scenario: scenario_type,
      location: location,
      description: scenario_text,
      design_image: design_image_url
    }, status: :ok
  end
end
