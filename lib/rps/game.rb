module RPS
  class Game
    attr_reader :game_id, :match_id, :started_at, :completed_at

    def initialize(args)
      @game_id      = args[:game_id]
      @match_id     = args[:match_id]
      @started_at   = args[:started_at]
      @completed_at = args[:completed_at]
    end

    def completed?
      @completed_at.nil? != nil
    end
  end
end
