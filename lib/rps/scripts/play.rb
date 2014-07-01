module RPS
  class Play
    def self.run(play_hash) # :game_id => 123, :player => player, :action => 'rock'
      match_id = play_hash[:match_id]
      game_id  = play_hash[:game_id]
      player   = play_hash[:player]
      action   = play_hash[:action]

      return_hash = { :player => player.to_json_hash, :errors => [] }

      # get match
      match = player.get_match(match_id)

      if match
        return_hash[:match] = match.to_json_hash

        # get opponent
        opponent = match.opponent_for(player)

        if opponent
          return_hash[:opponent] = opponent.to_json_hash
        end

        # get game
        game = match.get_current_game

        if game
          players_moves   = player.moves_for_game(game.game_id)
          opponents_moves = opponent.moves_for_game(game.game_id)

          if players_moves.empty?
            # create move
            if create_move(game, player, action, return_hash)
              # check to see if game is over and update
              if game.moves.length == 2
                game = RPS.db.update('games', ['game_id', game.game_id], {'completed_at' => Time.now}).first

                if game
                  # check winner
                  games = RPS.db.find('games',{'match_id' => match.match_id})
                  # get updated games

                  return_hash[:games] = []
                  games.each do |game|
                    game_hash = game.to_json_hash

                    game_hash[:moves] = []
                    game.moves.each do |move|
                      game_hash[:moves].push(move.to_json_hash)
                    end

                    return_hash[:games].push(game_hash)
                  end
                  # return_hash[:games] = games

                  # get_score_for(games, player, opponent, return_hash)
                  score_hash = RPS::GetScore.run(match, player, opponent, games)
                  return_hash.merge!(score_hash)

                  # check if match is over
                  if return_hash[:winner]
                    match = RPS.db.update('matches', ['match_id', match.match_id], {'completed_at' => Time.now})
                    return_hash[:match] = match.to_json_hash
                  else
                    # create a new game
                    new_game = RPS.db.create('games', {'match_id' => match.match_id}).first
                    return_hash[:game] = new_game.to_json_hash
                  end
                  return_hash
                else
                  return_hash[:errors].push('unable to update game')
                end

              end
            else
              return_hash[:errors].push('unable to create move')
            end
          else
            # error you already made your move
            # return_hash[:success?] = false
            return_hash[:errors].push('you already made a move')
          end
        else # return a error
          # return_hash[:success?] = false
          return_hash[:errors  ].push('invalid game')
        end
      else
        # invalid match
        # return_hash[:success?] = false
        return_hash[:errors  ].push('invalid match')
      end

      return_hash
    end

    private

    def self.create_move(game, player, action, response_hash)
      new_move = RPS.db.create('moves', {'game_id' => game.game_id, 'player_id' => player.player_id, 'action' => action}).first
      if new_move
        true
      else
        response_hash[:errors].push('could not create the move')
        false
      end
    end
  end
end
