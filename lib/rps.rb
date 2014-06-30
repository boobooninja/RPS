module RPS
end

require 'digest'
require 'time'
require 'pg'
require 'securerandom'
require 'json'

require_relative 'rps/db.rb'
require_relative 'rps/session.rb'
require_relative 'rps/move.rb'
require_relative 'rps/player.rb'
require_relative 'rps/game.rb'
require_relative 'rps/match.rb'
require_relative 'rps/scripts/signup.rb'
require_relative 'rps/scripts/sign_in.rb'
require_relative 'rps/scripts/validate_session.rb'
require_relative 'rps/scripts/delete_session.rb'
require_relative 'rps/scripts/play.rb'
require_relative 'rps/scripts/join_match.rb'
require_relative 'rps/scripts/create_match.rb'
require_relative 'rps/scripts/get_score.rb'
