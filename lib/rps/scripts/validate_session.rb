module RPS
  class ValidateSession
    def self.run(params) # :session_id => "session_id"
      # check to see if session is valid
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
