module RPS
  class MatchHistory
    def self.run(params, match)
      games = match.games

      games_array = [ ]

      games.each do |game|
        if game.completed_at
          game_hash = game.to_json_hash
          game_hash[:moves] = []

          game.moves.each do |move|
            game_hash[:moves].push(move.to_json_hash)
          end

          games_array.push(game_hash)
        end
      end

      if games_array.empty? == false
        { :success? => true, :games => games_array, :errors => [ ] }
      else
        { :success? => false, :games => games_array, :errors => ['unable to get history'] }
      end
    end
  end
end
