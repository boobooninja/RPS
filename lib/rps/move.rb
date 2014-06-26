module RPS
  class Move
    attr_reader :id, :game_id, :player_id, :action

    def initialize(args)
      @id        = args[:id]
      @game_id   = args[:game_id]
      @player_id = args[:player_id]
      @action    = args[:action]
    end
  end
end
