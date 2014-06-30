module RPS
  class JoinMatch
    def self.run(params, player)
      match = RPS.db.find('matches',{'started_at' => nil}).first
      member = false

      match.players.each do |p|
        if p.player_id == player.player_id
          member = true
        end
      end

      if match && !member
        match = RPS.db.update('matches', {'started_at' => Time.now}).first
        playermatches = RPS.db.create('playermatches', {'match_id' => match.match_id, 'player_id' => player.player_id})
        game  = RPS.db.update('games', ['game_id', game.game_id], {'started_at' => Time.now})

        { :success? => true, :match => match, :game => game, :errors => [ ] }
      else
        { :success? => false, :errors => [] }
      end
    end
  end
end
