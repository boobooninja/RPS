module RPS
  class SignIn
    def self.run(params) # :username => "username", :password => "mypassword"
      # check to see if player exists
      player = RPS.db.find('players',{:username => params[:username]}).first
      if player # create a session
        # validate password
        if player.has_password?(params[:password])
          session_id = SecureRandom.base64
          session = RPS.db.create('sessions', {:session_id => session_id, :player_id => player.id})

          { :success? => true, :session_id => session_id, :player => player, :errors => [] }
        else
          { :success? => false, :errors => ['invalid password'] }
        end
      else # return a error
        { :success? => false, :errors => ['invalid username'] }
      end
    end
  end
end