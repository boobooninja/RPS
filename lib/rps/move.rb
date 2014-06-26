module RPS
  class Move
    attr_reader :id, :game_id, :player_id, :name

    def initialize(args)
      @id        = args[:id]
      @game_id   = args[:game_id]
      @player_id = args[:player_id]
      @name      = args[:name]
    end
  end
end
