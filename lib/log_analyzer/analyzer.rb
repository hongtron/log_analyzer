module LogAnalyzer
  class Analyzer
    BUCKET_SPAN_SECONDS = 10
    TRAFFIC_MONITORING_WINDOW_SECONDS = 120
    DEFAULT_REQUESTS_PER_SEC_THRESHOLD = 10

    def initialize(input)
      @input = input
      @output = STDOUT
      @clock = Clock.new
      @monitor = RollingWindowTrafficCheck.new(
        @clock,
        TRAFFIC_MONITORING_WINDOW_SECONDS,
        DEFAULT_REQUESTS_PER_SEC_THRESHOLD,
      )
      start_new_bucket
    end

    def run
      results = if @input == STDIN
        analyze(@input)
      else
        analyze(File.new(@input.first))
      end
    end

    def get_rows(input, options)
      if input == STDIN
        CSV(STDIN, **options) do |csv_in|
          csv_in.each do |row|
            yield row
          end
        end
      else
        CSV.foreach(input, **options) do |row|
          yield row
        end
      end
    end

    def analyze(input)
      LogAnalyzer::LOGGER.debug("Analyzing #{input == STDIN ? "STDIN" : input.path}")
      current_time = 0
      get_rows(input, headers: true) do |row|
        @clock.tick(row)
        @monitor.record_hit_and_run_check!(output, LogParser.epoch_time(row))

        if @bucket.expired?
          @bucket.summarize(@output)
          start_new_bucket
        end
        @bucket.ingest(row)
      end
    end

    def start_new_bucket
      @bucket = Bucket.new(@clock, BUCKET_SPAN_SECONDS)
    end
  end
end
