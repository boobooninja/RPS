module RPS
  class Player
    attr_reader :player_id, :name, :username, :pwd

    def initialize(args)
      @player_id = args[:player_id]
      @name      = args[:name]
      @username  = args[:username]
      @pwd       = args[:pwd]
    end

    def update_password(password)
      @pwd = Digest::SHA1.hexdigest(password)
    end

    def has_password?(password)
      incoming_password = Digest::SHA1.hexdigest(password)
      incoming_password == @pwd
    end

    def get_match(match_id)
      RPS.db.find('matches, playermatches',{'matches.match_id' => match_id, 'playermatches.player_id' => @player_id}).first
    end

    def matches
      @matches ||= RPS.db.find('matches, playermatches', {'player_id' => @player_id})
    end

    def games_for_match(match_id)
      @games ||= RPS.db.find('games',{'match_id' => match_id})
    end

    def moves_for_game(game_id)
      @moves ||= RPS.db.find('moves',{'game_id' => game_id})
    end

    def score
      @score
    end

    def to_json_hash
      {:player_id => @player_id, :name => @name, :username => @username}
    end

    private

    def score=(num)
      @score = num
    end
  end
end
