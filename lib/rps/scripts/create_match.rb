module RPS
  class CreateMatch
    def self.run(params, player)
      match = RPS.db.create('matches',{}).first
      result = RPS.db.create_playermatches('playermatches',{:player_id => player.id, :match_id => match.id})

      if match && result
        { :success? => true, :match => match, :errors => [ ] }
      else
        { :success? => false, :errors => ['unable to create match'] }
      end
    end
  end
end
