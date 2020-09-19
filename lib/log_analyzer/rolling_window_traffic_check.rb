module LogAnalyzer
  class RollingWindowTrafficCheck
    WINDOW_SIZE = 120 # seconds

    def initialize(clock, threshold)
      @clock = clock
      @threshold = threshold # requests/sec
      @hits = initial_data_point
      @triggered = false
    end

    def record_hit_and_run!(output, hit_time)
      roll_window!

      total_hits = 0
      current_datapoint = @hits
      while current_datapoint do
        if current_datapoint.timestamp < hit_time
          if current_datapoint.next.nil? || current_datapoint.next.timestamp > hit_time
            current_datapoint.next = TimeseriesDataPoint.new(hit_time, next_point: current_datapoint.next)
          end
        elsif hit_time == current_datapoint.timestamp
          current_datapoint.increment_count
        end

        total_hits += current_datapoint.count
        current_datapoint = current_datapoint.next
      end

      check!(output, total_hits)
    end

    def window_start
      @clock.current_time - WINDOW_SIZE
    end

    def roll_window!
      while @hits && @hits.timestamp < window_start
        @hits = @hits.next
      end

      # create a new timeseries head if everything has rolled out of the window
      @hits ||= initial_data_point
    end

    def initial_data_point
      TimeseriesDataPoint.new(@clock.current_time)
    end

    def check!(output, total_hits)
      current_hit_rate = total_hits / WINDOW_SIZE
      LogAnalyzer::LOGGER.debug("Current hit rate is #{current_hit_rate}")
      if triggered? && current_hit_rate < @threshold
        output.puts <<~EOS
          Traffic returned to normal - hits = #{total_hits}, recovered at time #{@clock.current_time}
        EOS
        @triggered = false
      elsif !triggered? && current_hit_rate >= @threshold
        @triggered = true
        output.puts <<~EOS
          High traffic generated an alert - hits = #{total_hits}, triggered at time #{@clock.current_time}
        EOS
      else
        LogAnalyzer::LOGGER.debug("Alert status unchanged at time #{@clock.current_time}")
      end
    end

    def triggered?
      @triggered
    end
  end
end
