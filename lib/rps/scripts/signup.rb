module RPS
  class SignUp
    def self.run(params) # :name = params[:name], :username => params[:username], :password => params[:password]
      name = params[:name]
      username = params[:username]
      password = params[:password]

      # if username && password
      #   args = {}
      #   args[:name] = name if name
      #   args[:username] = username
      #   args[:password]
      #   player = RPS.db.create('players', {:name => session_id, :player_id => player.id})

      # # check to see if player exists
      # player = RPS.db.find('players',{:username => params[:username]}).first
      # if player # create a session
      #   # validate password
      #   if player.has_password?(params[:password])
      #     session_id = SecureRandom.base64
      #     session = RPS.db.create('sessions', {:session_id => session_id, :player_id => player.id})

      #     { :success? => true, :session_id => session_id, :player => player, :errors => [] }
      #   else
      #     { :success? => false, :errors => ['invalid password'] }
      #   end
      # else # return a error
      #   { :success? => false, :errors => ['invalid username'] }
      # end
    end
  end
end
