module RPS
  class SignIn
    def self.run(params) # :username => "username", :password => "mypassword"
      username = params[:username]
      password = params[:password]

      if username && password
        # check to see if player exists
        player = RPS.db.find('players',{:username => username}).first
        if player # create a session
          # validate password
          if player.has_password?(password)
            rps_session_id = SecureRandom.base64
            rps_session = RPS.db.create('sessions', {:session_id => rps_session_id, :player_id => player.player_id}).first

            if rps_session
              { :success? => true, :rps_session_id => rps_session.session_id, :player => player, :errors => [] }
            else
              { :success? => false, :errors => ['unable to create a session'] }
            end
          else
            { :success? => false, :errors => ['invalid password'] }
          end
        else # return a error
          { :success? => false, :errors => ['invalid username'] }
        end
      else
        { :success? => false, :errors => ['username and password are required'] }
      end
    end
  end
end
