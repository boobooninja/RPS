module RPS
  class Play
    def self.run(params) # :game_id => 123, :player => player, :action => 'rock'
      match_id = params[:match_id]
      game_id  = params[:game_id]
      player   = params[:player]
      action   = params[:action]

      return_hash = { :player => player, :errors => [] }

      # get matches
      matches = RPS.db.find('matches, playermatches',{'player_id' => player.id})

      # get match
      matches.each do |m|
        match = m if m.id == match_id
      end

      if match
        return_hash[:match] = match
        # get games
        games = RPS.db.find('games',{'match_id' => match.id})

        # get game
        games.each do |g|
          game = g if g.id == game_id
        end

        if game
          return_hash[:game] = game
          # get moves
          moves = RPS.db.find('moves',{'game_id' => game.id})

          if moves.nil?
            # create move
            return_hash = create_move(game, player, action, return_hash)
          elsif moves.count == 1
            if moves.first.player_id != player.id
              other_players_move = moves.first
              # create move
              return_hash = create_move(game, player, action, return_hash)
              if return_hash[:success?]
                # check winner
                this_players_move = return_hash[:move]
                score = check_winner(this_players_move, other_players_move)
# TODO
                # update game
                game = RPS.db.update('games', ['game_id', game.id], {'completed_at' => Time.now}).first
                if game
                return_hash[:game] = game
                  # check if match is over
                  # TODO
                else
                  return_hash[:errors].push('unable to update game')
                end
              end
              return_hash
            else
              return_hash[:success?] = false
              return_hash[:errors  ].push('you already made your move')
              return_hash
            end
          elsif moves.count == 2
            return_hash[:success?] = false
            return_hash[:errors  ].push('this game is already over')
            return_hash
          end
        else # return a error
          return_hash[:success?] = false
          return_hash[:errors  ].push('invalid game')
          return_hash
        end
      end
    end

    private

    def self.create_move(game, player, action, response_hash)
      new_move = RPS.db.create('moves', {'game_id' => game.id, 'player_id' => player.id, 'action' => action}).first
      if new_move
        response_hash[:success?] = true
        response_hash[:move]     = new_move
        response_hash
      else
        response_hash[:success?] = false
        response_hash[:errors].push('could not create the move')
        response_hash
      end
    end

    def self.check_winner(this_players_move, other_players_move)
      result = this_players_move.wins?(other_players_move)
# check if match is over
# match number
# we need to know who won
# each players score
# game number
# create and return new game
# { :success? => true, :player => player, :game => game, :errors => ['you already made your move'] }
      if result == true

      elsif result == false

      elsif result == :tie

      end
    end
  end
end
