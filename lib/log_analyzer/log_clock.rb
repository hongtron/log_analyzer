module LogAnalyzer
  class LogClock
    attr_reader :current_time

    def initialize
      @current_time = -1
    end

    def tick(log_time)
      @current_time = [@current_time, log_time].max
    end
  end
end
