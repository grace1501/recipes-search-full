require "sinatra"
require "sinatra/reloader"
require "http"

get("/") do
  
  erb(:homepage)
end

get("/recipes") do

  erb(:recipes)
end

get("/random") do

  erb(:random)
end
