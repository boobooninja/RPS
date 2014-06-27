# required gem includes
require 'sinatra'
require "sinatra/json"

# require file includes
require_relative 'lib/rps.rb'

enable :sessions

set :bind, '0.0.0.0' # Vagrant fix
set :port, 9494

get '/' do
  if session[:session_id]
    result = RPS::ValidateSession.run(:session_id => session[:session_id])
    if result[:success?]
      @player = result[:player]
      erb :home
    else
      erb :main
    end
  else
    erb :main
  end
end

get '/signin' do
  if session[:session_id]
    result = RPS::ValidateSession.run(:session_id => session[:session_id])
    if result[:success?]
      @player = result[:player]
      erb :home
    end
  else
    result = RPS::SignIn.run(:username => params[:username], :password => params[:password])
    if result[:success?]
      session[:session_id] = result[:session_id]
      @player = result[:player]
      erb :home
    else
      @error = result[:error]
      erb :signin
    end
  end
end

get '/player/:player_id/signout' do
  result = RPS::DeleteSession.run(:session_id => session[:session_id])

  session[:session_id] = nil

  erb :main
end

get '/match/:match_id/game/:game_id' do
  if session[:session_id]
    result = RPS::ValidateSession.run(:session_id => session[:session_id])
    if result[:success?]
      @player = result[:player]
      @match  = RPS.db.find('matches, playermatches',{:player_id => @player.id, :completed_at => null})
      @games  = RPS.db.find('games, moves',{:match_id => @match.id})
      erb :game
    else
      @error = result[:error]
      erb :signin
    end
  else
    erb :signin
  end
end

# get '/employees' do
#   @employees = TM.db.find('employees', {})
#   erb :employees
# end


# configure do
#   jokesKlass = MyApp::Jokes.new
#   @@jokes = jokesKlass.jokes
# end

# get '/' do
#   # This goes in your <%= yield %> statement
#   # seen in your main layout.erb file
#   @im_some_ruby_var = "Hey, this is a web app"
#   erb :test # layout implied
# end

# get '/js-specs' do
#   erb :specs, :layout => :spec
# end

# get '/jokes-js-ui' do
#   erb :jokes
# end


#-------- JSON API routes -----------

# # more info sinatra json: http://www.sinatrarb.com/contrib/json.html
# get '/api/jokes' do
#   json @@jokes
# end

# post '/api/jokes/create' do
#   original_jokes_length = @@jokes.count
#   if params[:joke]['joke'].empty? || params[:joke]['answer'].empty?
#     response = {success: false, message: "you did fill things in"}
#   else
#     @@jokes.push(params[:joke])
#     if @@jokes.count == original_jokes_length + 1
#       response = {success: true, message: "You Added joke correctly"}
#     else
#       response = {success: false, message: "Something went wrong"}
#     end
#   end
#   json response
# end
