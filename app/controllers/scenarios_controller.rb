class ScenariosController < ApplicationController
  def generate
    service = ChatGptService.new
    location = params[:location]
    scenario_type = params[:scenario_type] == "" ? 'foodGarden' : params[:scenario_type] 
    photos = params[:photos]
    
    scenario_text = case scenario_type
    when 'foodGarden'
      service.generate_scenario("Suggest food-producing plants for a backyard in #{location}. Return each plant with its name and description.")
    when 'ecoFriendly'
      service.generate_scenario("Suggest native, eco-friendly plants for a sustainable backyard in #{location}. Return each plant with its name and description.")
    when 'mixed'
      service.generate_scenario("Combine food-producing and eco-friendly plants for a backyard in #{location}. Return each plant with its name and description.")
    else
      render json: { error: "Invalid scenario type selected." }, status: :bad_request and return
    end

    #get list of plants from ChatGpt
    # binding.pry
    
    # if scenario_text.size > 0 
    #   plants = scenario_text.map { |plant| plant["name"] }
    #   plants.each do |plant|
    #     photo_plants << service_plant.fetch_plant_data(plant)
    #   end
    # end
      

    # Integrate with ImageGenerationService and pass the photo URLs
    design_image_url = ImageGenerationService.new.generate_design(scenario_text, photos)

    render json: {
      scenario: scenario_type,
      location: location,
      description: "Here are recommended plants for your backyard in #{location}.",
      design_image: design_image_url,
      plants: scenario_text, # This should be a structured array of plant data
    }, status: :ok
  end
end
