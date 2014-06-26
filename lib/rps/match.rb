module RPS
  class Match
    attr_reader :id, :started_at, :completed_at

    def initialize(args)
      @id           = args[:id]
      @started_at   = args[:started_at]
      @completed_at = args[:completed_at]
    end

    def completed?
      @completed_at.nil? != nil
    end

  end
end
