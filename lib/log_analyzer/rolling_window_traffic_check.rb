module LogAnalyzer
  class RollingWindowTrafficCheck
    WINDOW_SIZE = 120 # seconds

    attr_reader :hits

    def initialize(clock, threshold)
      @clock = clock
      @threshold = threshold # requests/sec
      @hits = initial_data_point
      @triggered = false
    end

    def record_hit_and_perform_check!(output, hit_time)
      _roll_window!

      raise "Invalid state; did you forget to tick the clock to #{hit_time}?" if hit_time > @clock.current_time

      total_hits = 0
      current_datapoint = @hits
      while current_datapoint do
        if current_datapoint.timestamp < hit_time
          if current_datapoint.next.nil? || current_datapoint.next.timestamp > hit_time
            # insert a new datapoint that can be incremented on the next iteration
            current_datapoint.next = TimeseriesDataPoint.new(hit_time, next_point: current_datapoint.next)
          end
        elsif hit_time == current_datapoint.timestamp
          current_datapoint.increment_count
        end

        total_hits += current_datapoint.count
        current_datapoint = current_datapoint.next
      end

      _check!(output, total_hits)
    end

    def window_start
      @clock.current_time - WINDOW_SIZE
    end

    def _roll_window!
      while @hits && @hits.timestamp < window_start
        @hits = @hits.next
      end

      # create a new timeseries head if everything has rolled out of the window
      @hits ||= initial_data_point
    end

    def initial_data_point
      current_time = @clock.current_time
      LogAnalyzer::LOGGER.debug("Initializing new timeseries starting at #{current_time}")
      TimeseriesDataPoint.new(current_time)
    end

    def _check!(output, total_hits)
      current_hit_rate = total_hits / WINDOW_SIZE
      LogAnalyzer::LOGGER.debug("Current hit rate is #{current_hit_rate} requests/sec (trigger state: #{triggered?})")
      if triggered?
        if current_hit_rate < @threshold
          output.puts <<~EOS
            Traffic returned to normal - hits = #{total_hits} (rate: #{current_hit_rate} requests/sec), recovered at #{Time.at(@clock.current_time)}
          EOS
          @triggered = false
        else
          LogAnalyzer::LOGGER.debug("Elevated traffic - rate = #{current_hit_rate} requests/sec")
        end
      elsif current_hit_rate >= @threshold
        @triggered = true
        output.puts <<~EOS
          High traffic generated an alert - hits = #{total_hits} (rate: #{current_hit_rate} requests/sec), triggered at time #{Time.at(@clock.current_time)}
        EOS
      end
    end

    def triggered?
      @triggered
    end
  end
end
