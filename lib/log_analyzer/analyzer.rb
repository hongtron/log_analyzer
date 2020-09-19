module LogAnalyzer
  class Analyzer
    BUCKET_SPAN_SECONDS = 10

    def initialize(input, alert_threshold)
      @input = input
      @output = STDOUT
      @clock = LogClock.new
      @check = RollingWindowTrafficCheck.new(@clock, alert_threshold)
      _start_new_bucket
    end

    def run
      LogAnalyzer::LOGGER.debug("Analyzing #{@input == STDIN ? "STDIN" : @input}")
      current_time = 0
      _get_rows(headers: true) do |row|
        @clock.tick(row)
        @check.record_hit_and_run!(@output, LogParser.epoch_time(row))

        if @bucket.expired?
          @bucket.summarize(@output)
          _start_new_bucket
        end
        @bucket.ingest(row)
      end
    end

    def _get_rows(csv_options)
      if @input == STDIN
        CSV(STDIN, **csv_options) do |csv_in|
          csv_in.each do |row|
            yield row
          end
        end
      else
        CSV.foreach(@input, **csv_options) do |row|
          yield row
        end
      end
    end

    def _start_new_bucket
      @bucket = Bucket.new(@clock, BUCKET_SPAN_SECONDS)
    end
  end
end
