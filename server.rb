# required gem includes
require 'sinatra'
require "sinatra/json"

# require file includes
require_relative 'lib/rps.rb'

enable :sessions

set :bind, '0.0.0.0' # Vagrant fix
set :port, 9494

get '/' do
  result = RPS::ValidateSession.run(:session_id => session[:session_id])
  @errors = result[:errors]

  if result[:success?]
    @player = result[:player]
    erb :home
  else
    erb :index
  end
end

get '/signup' do
  result = RPS::ValidateSession.run(:session_id => session[:session_id])
  @errors = result[:errors]

  if result[:success?]
    @player = result[:player]
    erb :home
  else
    erb :signup
  end
end

post '/signup' do
  result = RPS::ValidateSession.run(:session_id => session[:session_id])
  @errors = result[:errors]

  if result[:success?]
    @errors.push('Please logout first before signing up')
    @player = result[:player]
    erb :home
  else
    result = RPS::SignUp.run(:name => params[:name], :username => params[:username], :password => params[:password])
    @errors.push(result[:errors]).flatten

    if result[:success?]
      result = RPS::SignIn.run(:username => params[:username], :password => params[:password])
      @errors.push(result[:errors]).flatten

      if result[:success?]
        session[:session_id] = result[:session_id]
        @player = result[:player]
        erb :home
      else
        erb :login
      end
    else
      erb :login
    end
  end
end

get '/login' do
  result = RPS::ValidateSession.run(:session_id => session[:session_id])
  @errors = result[:errors]

  if result[:success?]
    @player = result[:player]
    erb :home
  else
    result = RPS::SignIn.run(:username => params[:username], :password => params[:password])
    @errors.push(result[:errors]).flatten

    if result[:success?]
      session[:session_id] = result[:session_id]
      @player = result[:player]
      erb :home
    else
      erb :login
    end
  end
end

get '/signout' do
  result = RPS::DeleteSession.run(:session_id => session[:session_id])
  @errors = result[:errors]

  if result[:success?]
    session[:session_id] = nil
    erb :main
  else
    erb :main
  end
end

get '/match/:match_id/game/:game_id' do
  result = RPS::ValidateSession.run(:session_id => session[:session_id])
  @errors = result[:errors]

  if result[:success?]
    @player = result[:player]
    @match  = RPS.db.find('matches, playermatches',{:player_id => @player.id, :completed_at => null}).first
    @games  = RPS.db.find('games, moves',{:match_id => @match.id})
    erb :game
  else
    erb :login
  end
end

#-------- JSON API routes -----------

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
