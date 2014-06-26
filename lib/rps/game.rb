module RPS
  class Game
    attr_reader :id, :match_id, :started_at, :completed_at

    def initialize(args)
      @id           = args[:id]
      @match_id     = args[:match_id]
      @started_at   = args[:started_at]
      @completed_at = args[:completed_at]
    end

    def completed?
      @completed_at.nil? != nil
    end
  end
end
