module RPS
  class Player
    attr_reader :id, :name, :username, :pwd

    def initialize(args)
      @id       = args[:id]
      @name     = args[:name]
      @username = args[:username]
      @pwd      = args[:pwd]
    end

    def update_password(password)
      @pwd = Digest::SHA1.hexdigest(password)
    end

    def has_password?(password)
      incoming_password = Digest::SHA1.hexdigest(password)
      incoming_password == @pwd
    end
  end
end
