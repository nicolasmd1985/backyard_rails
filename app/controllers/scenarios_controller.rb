class ScenariosController < ApplicationController
  def generate
    service = ChatGptService.new
    location = params[:location]
    scenario_type = params[:scenario_type]

    # Use the appropriate method to generate the response
    scenario_text = case scenario_type
    when 'food_garden'
      service.generate_scenario("Suggest food-producing plants for a backyard in #{location}.")
    when 'eco_friendly'
      service.generate_scenario("Suggest native, eco-friendly plants for a sustainable backyard in #{location}.")
    when 'mixed'
      service.generate_scenario("Combine food-producing and eco-friendly plants for a backyard in #{location}.")
    else
      "Invalid scenario type selected."
    end

    render json: {
      scenario: scenario_type,
      location: location,
      description: scenario_text
    }, status: :ok
  end
end
