module LogAnalzer
  class RollingWindowTrafficCheck
    def initialize(clock, window, threshold)
      @clock = clock
      @window = window
      @threshold = threshold # requests/sec
      @hits = TimeseriesDataPoint.new(@clock.current_time)
      @triggered = false
    end

    def record_hit_and_run_check!(output, hit_time)
      roll_window!

      total_hits = 0
      current_datapoint = @hits
      while current_datapoint do
        if hit_time == current_datapoint.timestamp
          current_datapoint.increment_count
          total_hits += current_datapoint.count
          current_datapoint = current_datapoint.next
        end
      end

      check!(output, total_hits)
    end

    def window_start
      @clock.current_time - @window
    end

    def roll_window!
      while @hits && @hits.timestamp < window_start
        @hits = @hits.next
      end

      # create a new timeseries head if everything has rolled out of the window
      @hits ||= TimeseriesDataPoint.new(@clock.current_time)
    end

    def check!(output, total_hits)
      current_hit_rate = total_hits / @window
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
