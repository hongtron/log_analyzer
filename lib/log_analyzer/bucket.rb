module LogAnalyzer
  class Bucket
    STAT_RANK_CUTOFF = 5

    def initialize(clock, span)
      @clock = clock
      @span = span
      @start_time = @clock.current_time
      @end_time = @start_time + @span
      @section_hits = Hash.new(0)
    end

    def ingest(row)
      @section_hits[LogParser.section(row)] += 1
    end

    def summarize(output)
      output.puts <<~EOS
        Top #{most_trafficked_sections.length} most trafficked sections for #{Time.at(@start_time)} to #{Time.at(@end_time)} - #{most_trafficked_sections_summary}
      EOS
    end

    def expired?
      @clock.current_time > @end_time
    end

    def most_trafficked_sections_summary
      most_trafficked_sections.map do |hits, section|
        "#{section} (hits: #{hits})"
      end.join(", ")
    end

    def most_trafficked_sections
      @section_hits
        .invert
        .sort_by(&:first)
        .reverse
        .take(STAT_RANK_CUTOFF)
        .to_h
    end
  end
end
