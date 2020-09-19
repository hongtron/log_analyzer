module LogAnalyzer
  class TimeseriesDataPoint
    attr_accessor :next
    attr_reader :timestamp, :count

    def initialize(timestamp)
      @timestamp = timestamp
      @count = 1
      @next = nil
    end

    def increment_count
      @count += 1
    end
  end
end
