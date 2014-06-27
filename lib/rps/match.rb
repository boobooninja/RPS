module RPS
  class Match
    attr_reader :match_id, :started_at, :completed_at

    def initialize(args)
      @match_id     = args[:match_id]
      @started_at   = args[:started_at]
      @completed_at = args[:completed_at]
    end

    def completed?
      @completed_at.nil? != nil
    end

    def players
      @players ||= TM.db.find('players, playermatches', {'match_id' => @match_id})
    end
  end
end
