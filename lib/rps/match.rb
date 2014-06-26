module RPS
  class Match
    attr_reader :id, :player_1_id, :player_2_id, :started_at, :completed_at

    def initialize(args)
      @id           = args[:id]
      @player_1_id  = args[:player_1_id]
      @player_2_id  = args[:player_2_id]
      @started_at   = args[:started_at]
      @completed_at = args[:completed_at]
    end

    def completed?
      @completed_at.nil? != nil
    end

  end
end
