module RPS
  class ValidateSession
    def self.run(params)
      rps_session_id = params[:rps_session_id]

      if rps_session_id
        session = RPS.db.find('sessions', {:session_id => rps_session_id}).first

        if session # get player
          player = RPS.db.find('players',{:player_id => session.player_id}).first
          { :success? => true, :player => player, :errors => [] }
        else # return a error
          { :success? => false, :errors => ['player no longer exists'] }
        end
      else
        { :success? => false, :errors => ['invalid session'] }
      end
    end
  end
end
