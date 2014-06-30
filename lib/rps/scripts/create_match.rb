module RPS
  class CreateMatch
    def self.run(params, player)
      match = RPS.db.create('matches',{'started_at' => Time.now}).first
      result = RPS.db.create_playermatches('playermatches',{:player_id => player.player_id, :match_id => match.match_id})
      game = RPS.db.create('games', {'match_id' => match.match_id}).first

      if match && result && game
        { :success? => true, :match => match, :game => game, :errors => [ ] }
      else
        { :success? => false, :errors => ['unable to create match'] }
      end
    end
  end
end
