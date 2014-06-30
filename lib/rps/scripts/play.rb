module RPS
  class Play
    def self.run(params) # :game_id => 123, :player => player, :action => 'rock'
      match_id = params[:match_id]
      game_id  = params[:game_id]
      player   = params[:player]
      action   = params[:action]

      return_hash = { :player => player.to_json_hash, :errors => [] }

      # get matches
      matches = player.matches
      # matches = RPS.db.find('matches, playermatches',{'player_id' => player.id})

      # get match
      matches.each do |m|
        match = m if m.id == match_id
      end

      if match
        return_hash[:match] = match.to_json_hash

        # get opponent
        match.players.each do |p|
          opponent = p if p.player_id != player.id
        end

        if opponent
          return_hash[:opponent] = opponent.to_json_hash
        end

        # get games
        games = match.games
        # games = RPS.db.find('games',{'match_id' => match.id})

        # get game
        games.each do |g|
          game = g if g.id == game_id
        end

        if game
          # return_hash[:game] = game
          # get moves
          # moves = game.moves
          # moves = RPS.db.find('moves',{'game_id' => game.id})

          players_moves   = player.moves_for_game(game.id)
          opponents_moves = opponent.moves_for_game(game.id)

          if players_moves.empty?
            # create move
            if create_move(game, player, action, return_hash)
              # update game
              game = RPS.db.update('games', ['game_id', game.id], {'completed_at' => Time.now}).first
              if game
                # return_hash[:game] = game
                # check winner
                games = RPS.db.find('games',{'match_id' => match.id})
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

                get_score_for(games, player, opponent, return_hash)

                # check if match is over
                if return_hash[:winner]
                  match = RPS.db.update('match', ['match_id', match.id], {'completed_at' => Time.now})
                  return_hash[:match] = match.to_json_hash
                else
                  # create a new game
                  new_game = RPS.db.create('games', {'match_id' => match.id}).first
                  return_hash[:game] = new_game.to_json_hash
                end
                return_hash
              else
                return_hash[:errors].push('unable to update game')
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
      new_move = RPS.db.create('moves', {'game_id' => game.id, 'player_id' => player.id, 'action' => action}).first
      if new_move
        # response_hash[:success?] = true
        # response_hash[:move]     = new_move
        # response_hash
        true
      else
        # response_hash[:success?] = false
        response_hash[:errors].push('could not create the move')
        # response_hash
        false
      end
    end

    def self.get_score_for(games, player, opponent, return_hash)
      player_score   = 0
      opponent_score = 0

      games.each do |game|
        games.moves.each do |move|
          player_move = move if move.player_id == player.id
          opponent_move = move if move.player_id == opponent.id
        end
        result = player_move.wins?(opponent_move)
        if result == true
          player_score += 1
        elsif result == false
          opponent_score += 1
        end
      end

      # player.score= player_score
      # opponent.score= opponent_score

      return_hash[:player][:score] = player_score
      return_hash[:opponent][:score] = opponent_score

      if player_score >= 3 && player_score > opponent_score
        return_hash[:winner] = player.to_json_hash
      elsif opponent_score >= 3 && opponent_score > player_score
        return_hash[:winner] = opponent.to_json_hash
      end
      # return_hash[:player  ] = player
      # return_hash[:opponent] = opponent
      return_hash
    end
  end
end
