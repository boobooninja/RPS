module RPS
  class SignUp
    def self.run(params) # :name = params[:name], :username => params[:username], :password => params[:password]
      name     = params[:name]
      username = params[:username]
      password = params[:password]

      if username && password
        # check to see if player exists
        player = RPS.db.find('players',{:username => username}).first

        if player
          { :success? => false, :errors => ['username is already taken'] }
        else
          args = {}
          args[:name    ] = name if name
          args[:username] = username
          args[:pwd     ] = Digest::SHA1.hexdigest(password)

          player = RPS.db.create('players', args)

          { :success? => true, :player => player, :errors => [] }
        end
      else # return a error
        { :success? => false, :errors => ['invalid username or password'] }
      end
    end
  end
end
