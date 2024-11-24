require "sinatra"
require "sinatra/reloader"
require "http"

# Helper function to process the meal data

# Example of ingredients and measurements from the API:
# "strIngredient1": "Chicken",
# "strIngredient2": "Onion",
# "strIngredient3": "Tomatoes",
# "strMeasure1": "1.2 kg",
# "strMeasure2": "5 thinly sliced",
# "strMeasure3": "2 finely chopped",

def process_meal(meal_data)
  # clean the data, remove empty elements
  meal_obj = meal_data.delete_if {|key, value|
    value.nil? || value.strip.empty?
  }
  meal_obj[:meal_name] = meal_data.fetch("strMeal")
  meal_obj[:meal_instructions] = meal_data.fetch("strInstructions")
  meal_obj[:meal_photo] = meal_data.fetch("strMealThumb")
  
  # process all the ingredients and measurements
  # pair the ingredients with the corresponding measuremens
  ingredients_with_measurements = {}

  meal_data.select {|key, value|
    if key.to_s.start_with?("strIngredient") 
      # get the number
      ingredient_num = key.to_s.gsub("strIngredient", "")
      # find the measurement with the corresponding number
      measurement_key = "strMeasure#{ingredient_num}"
      measurement_value = meal_data.fetch(measurement_key, nil)
      ingredients_with_measurements.store(value, measurement_value)
    end
  }
  meal_obj.store(:ingredients_with_measurements, ingredients_with_measurements)
  return meal_obj
end 


# All routes start here

get("/") do
  erb(:homepage)
end

get("/recipes") do
  search_term = params.fetch("user_input")
  api_url = "https://www.themealdb.com/api/json/v1/1/search.php?s=#{search_term}"
  raw_response = HTTP.get(api_url).to_s
  response_json = JSON.parse(raw_response)
  recipes_list = response_json.fetch("meals")

  if recipes_list.nil?
    erb(:no_match)
  else
     # process all recipes in the list
     @clean_recipes_list = recipes_list.each { |element|
      process_meal(element)
    }
    erb(:recipes)
  end
end

get("/random") do
  api_url = "https://www.themealdb.com/api/json/v1/1/random.php"
  raw_response = HTTP.get(api_url)
  response_string = raw_response.to_s
  response_json = JSON.parse(response_string)

  @result = response_json.fetch("meals")[0]
  @meal_object = process_meal(@result)
  
  erb(:random)
end
