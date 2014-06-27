module RPS
  class Move
    attr_reader :move_id, :game_id, :player_id, :action

    def initialize(args)
      @move_id   = args[:move_id]
      @game_id   = args[:game_id]
      @player_id = args[:player_id]
      @action    = args[:action]
    end

    def wins?(other_move)
      if self.beats == other_move.action
        true
      elsif other_move.beats == self.action
        false
      elsif self.action == other_move.action
        :tie
      end
    end

    def beats
      { rock:     :scissors,
        paper:    :rock,
        scissors: :paper }[self.action]
    end
  end
end
