module RPS
  class Play
    def self.run(params) # :game_id => 123, :player => player, :action => 'rock'
      # check to see if player is associated with this game
      player = params[:player]


      session = RPS.db.find('sessions', {:session_id => params[:session_id]})

      if session # get player
        player = RPS.db.find('players',{:id => session.player_id})
        { :success? => true, :player => player }
      else # return a error
        { :success? => false, :error => :invalid_session }
      end
    end
  end
end
