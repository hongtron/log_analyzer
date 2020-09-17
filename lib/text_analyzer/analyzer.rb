module TextAnalyzer
  class Analyzer
    SEQUENCE_SIZE = 3
    RANK_CUTOFF = 100

    def initialize(input)
      @input = input
    end

    def run
      results = if @input == STDIN
        analyze(@input)
      elsif @input.length == 1
        analyze(File.new(@input.first))
      else
        individual_results = @input.map { |path| File.new(path) }
          .map { |file| Thread.new { Thread.current[:result] = analyze(file) } }
          .each(&:join)
          .map { |t| t[:result] }
        combine_results(individual_results)
      end

      top_results = get_most_common(results)
      display(top_results)
    end

    def analyze(input)
      TextAnalyzer::LOGGER.debug("Analyzing #{input == STDIN ? "STDIN" : input.path}")
      result = Hash.new(0)
      lookback_tokens = []
      input.each_line do |line|
        normalize!(line)
        tokens = lookback_tokens + line.split(" ")
        sequences(tokens).each { |seq| result[seq] += 1 }
        lookback_tokens = tokens.last(SEQUENCE_SIZE - 1)
      end

      result
    end

    def combine_results(results)
      TextAnalyzer::LOGGER.debug("Combining #{results.length} sets of results")
      results.reduce(Hash.new(0)) do |acc, result|
        acc.merge(result) { |seq, total_count, current_count| total_count + current_count }
      end
    end

    def normalize!(text)
      text.downcase!
      text.gsub!(/\s+/, ' ')
      text.gsub!(/[^a-zA-Z0-9_ ]/,'')
      text
    end

    def sequences(tokens)
      tokens.each_cons(SEQUENCE_SIZE)
    end

    def get_most_common(result)
      result.sort_by(&:last).reverse!.take(RANK_CUTOFF).compact.to_h.invert
    end

    def display(results)
      output = results.map do |count, sequence|
        "#{count} - #{sequence.join(" ")}"
      end.join(", ")

      STDOUT.puts(output)
    end
  end
end
