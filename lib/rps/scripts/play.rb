module RPS
  class Play
    def self.run(params) # :game_id => 123, :player => player, :action => 'rock'
      # check to see if player is associated with this game
      player = params[:player]

      game = RPS.db.find('playermatches, matches, games',{:player_id => player.id,
                                                          :completed_at => null,
                                                          :game_id => params[:game_id]}).first

      if game
        { :success? => true, :game => game, :errors => [] }
      else # return a error
        { :success? => false, :errors => ['invalid game'] }
      end
    end
  end
end
