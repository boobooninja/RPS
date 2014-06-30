module RPS
  class GetScore
    def self.run(match, player, opponent, games = nil)
      response_hash  = {}
      player_score   = 0
      opponent_score = 0

      games ||= match.games

      games.each do |game|
        player_move   = nil
        opponent_move = nil

        game.moves.each do |move|
          player_move   = move if move.player_id == player.player_id
          opponent_move = move if move.player_id == opponent.player_id
        end

        if player_move && opponent_move
          result = player_move.wins?(opponent_move)
          if result == true
            player_score += 1
          elsif result == false
            opponent_score += 1
          end
        end
      end

      response_hash[:player  ] = player.to_json_hash
      response_hash[:opponent] = opponent.to_json_hash

      response_hash[:player][:score] = player_score
      response_hash[:opponent][:score] = opponent_score

      if player_score >= 3 && player_score > opponent_score
        response_hash[:winner] = player.to_json_hash
      elsif opponent_score >= 3 && opponent_score > player_score
        response_hash[:winner] = opponent.to_json_hash
      end

      response_hash
    end
  end
end
