module LogAnalyzer
  class Bucket
    def initialize(clock, span)
      @clock = clock
      @span = span
      @start_time = @clock.current_time
      @end_time = @start_time + @span
      @section_hits = Hash.new(0)
    end

    def ingest(log)
      @section_hits[LogParser.section(log)] += 1
    end

    def summarize
    end

    def expired?
      @clock.current_time > @end_time
    end
  end
end
