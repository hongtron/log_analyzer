module LogAnalyzer
  class LogClock
    attr_accessor :current_time

    def initialize
      @current_time = -1
    end

    def tick(log)
      @current_time = [@current_time, LogParser.epoch_time(log)].max
    end
  end
end
