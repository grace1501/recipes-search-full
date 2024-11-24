require "sinatra"
require "sinatra/reloader"
require "http"

# Helper function to process the meal data

def process_meal(meal_data)
  meal_obj = {}
  meal_obj[:meal_name] = meal_data.fetch("strMeal")
  meal_obj[:meal_instructions] = meal_data.fetch("strInstructions")
  meal_obj[:meal_photo] = meal_data.fetch("strMealThumb")


  return meal_obj
end 

get("/") do
  
  erb(:homepage)
end

get("/recipes") do
  search_term = params.fetch("user_input")
  api_url = "https://www.themealdb.com/api/json/v1/1/search.php?s=#{search_term}"
  raw_response = HTTP.get(api_url).to_s
  response_json = JSON.parse(raw_response)
  @recipes_list = response_json.fetch("meals")

  if @recipes_list.nil?
    erb(:no_match)
  else
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
