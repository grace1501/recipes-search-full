require "sinatra"
require "sinatra/reloader"
require "http"

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
  @meal_name = @result.fetch("strMeal")
  @meal_instructions = @result.fetch("strInstructions")
  @meal_photo = @result.fetch("strMealThumb")
  
  erb(:random)
end
