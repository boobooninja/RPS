module RPS
  class Session
    attr_reader :id, :session_id, :player_id, :started_at

    def initialize(args)
      @id         = args[:id]
      @session_id = args[:session_id]
      @player_id  = args[:player_id]
      @started_at = args[:started_at]
    end

    def exipired?
      Time.now > @started_at + 3600000
    end
  end
end
