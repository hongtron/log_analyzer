module LogAnalyzer
  class LogClock
    attr_reader :current_time

    def initialize
      @current_time = -1
    end

    def tick(row)
      @current_time = [@current_time, LogParser.epoch_time(row)].max
    end
  end
end
