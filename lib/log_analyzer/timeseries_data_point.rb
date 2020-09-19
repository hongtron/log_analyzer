module LogAnalyzer
  class TimeseriesDataPoint
    attr_accessor :next
    attr_reader :timestamp, :count

    def initialize(timestamp, next_point: nil)
      @timestamp = timestamp
      @count = 0
      @next = next_point
    end

    def increment_count
      @count += 1
    end
  end
end
