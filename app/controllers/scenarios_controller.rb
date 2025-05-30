class ScenariosController < ApplicationController
  def generate
    service = ChatGptService.new
    location = params[:location]
    scenario_type = params[:scenario_type] == "" ? 'foodGarden' : params[:scenario_type] 
    photos = params[:photos]
    
    scenario_text = case scenario_type
    when 'foodGarden'
      description_gen = "Design a lush, sustainable food garden in #{location} that highlights edible plants naturally suited to the local soil, climate, and seasonal patterns. This garden should feature raised beds overflowing with a diverse mix of vegetables, aromatic herbs, and small fruit-bearing shrubs adapted to the region. Incorporate companion planting techniques—such as interspersing vegetables with marigolds and native wildflowers—to attract beneficial insects and foster natural pest control. Add a gently winding gravel pathway between the beds, and include eco-friendly elements like a rainwater collection barrel and a compost bin to enrich the soil and conserve resources. Enclose the area with a simple fence or natural hedging, ensuring no houses or buildings are visible. The overall ambiance should feel abundant, productive, and seamlessly connected to nature, encouraging one to embrace the nourishing bounty of a homegrown harvest."
      service.generate_scenario("Suggest food-producing plants for a backyard in #{location}. Return each plant with its name and description.")
    when 'ecoFriendly'
      description_gen = "Design an eco-friendly, nature-focused backyard garden in #{location} that honors the regional ecosystem, showcasing plant species native to the local climate and soil conditions. Fill the landscape with drought-tolerant wildflowers, pollinator-friendly shrubs, and hardy grasses that support local wildlife—especially butterflies, bees, and birds. Introduce a natural stone pathway that winds quietly through the garden, leading to a small seating area made of reclaimed wood where one can admire the subtle interplay of colors and textures. Integrate sustainable features such as a modest rainwater harvesting system, mulch to retain moisture, and hand-crafted birdhouses to encourage biodiversity. Enclose the space with a low, rustic fence or living hedge, ensuring no houses or buildings are visible. The atmosphere should feel harmonious, sustainable, and rooted in the rhythms of the surrounding environment, inspiring a deep appreciation for the region's native treasures."
      service.generate_scenario("Suggest native, eco-friendly plants for a sustainable backyard in #{location}. Return each plant with its name and description.")
    when 'mixed'
      description_gen = "Create a balanced backyard garden in #{location} that artfully blends ornamental native flora with carefully chosen edible plants suited to the regional conditions. Arrange graceful ornamental grasses, vibrant wildflowers, and hardy shrubs intermingled with patches of aromatic herbs, berry bushes, and leafy greens. A gently curving pathway of natural materials should meander through the plantings, leading to a simple wooden bench where one can pause and take in the subtle interplay of textures, colors, and scents. Incorporate eco-friendly elements like a small rainwater barrel and a compost station to support soil health and resource conservation. Frame the garden with a low fence or border of shrubs, ensuring no houses or buildings enter the scene. The resulting space should feel abundant, inviting, and deeply connected to the local ecosystem—an enchanting fusion of beauty and sustenance."
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
    # design_image_url = ImageGenerationService.new.generate_design(scenario_text, photos)
    begin
      design_image_url = DezgoImageGenerationService.new.generate_design(description_gen, photos)
      # design_image_url = ImageGenerationService.new.generate_design(scenario_text, photos)
      Rails.logger.info "Design Image URL: #{design_image_url}"
    rescue e => e
        render json: { error: "Error generating scenario: #{e.message}" }, status: :internal_server_error and return
    end
    render json: {
      scenario: scenario_type,
      location: location,
      description: "Here are recommended plants for your backyard in #{location}.",
      design_image: design_image_url,
      plants: scenario_text, # This should be a structured array of plant data
    }, status: :ok
  end
end
