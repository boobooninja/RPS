module RPS
  class Match
    attr_reader :match_id, :started_at, :completed_at

    def initialize(args)
      @match_id     = args[:match_id]
      @started_at   = args[:started_at]
      @completed_at = args[:completed_at]
    end

    def completed?
      @completed_at.nil? != nil
    end

    def players
      @players ||= RPS.db.find('players, playermatches', {'match_id' => @match_id})
    end

    def opponent_for(player)
      opponent = nil

      self.players.each do |p|
        if p.player_id != player.player_id
          opponent = p
        end
      end
      opponent
    end

    def games
      @games ||= RPS.db.find('games', {'match_id' => @match_id})
    end

    def get_game(game_id)
      RPS.db.find('games',{'match_id' => @match_id, 'game_id' => game_id}).first
    end

    def get_current_game
      RPS.db.find('games',{'match_id' => @match_id, 'completed_at' => nil}).first
    end

    def to_json_hash
      {:match_id => @match_id, :started_at => @started_at, :completed_at => @completed_at}
    end
  end
end
