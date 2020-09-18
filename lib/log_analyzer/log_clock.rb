module LogAnalyzer
  class Clock
    attr_accessor :current_time

    def initialize
      @current_time = -1
    end

    def tick(log)
      @current_time = [@current_time, log.time].max
    end
  end
end
