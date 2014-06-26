module RPS
  class SignIn
    def self.run(params) # :username => "username", :password => "mypassword"
      # check to see if player exists
      player = RPS.db.find('players',{:username => params[:username]})
      if player # create a session
        # validate password
        if player.has_password?(params[:password])
          # WIP
          # session = RPS.db.create('sessions', {:session_id => ???, :player_id => player.id})

          { :success? => true, :session_id => session_id }
        else
          { :success? => false, :error => :invalid_password }
        end
      else # return a error

      end
    end
  end
end
