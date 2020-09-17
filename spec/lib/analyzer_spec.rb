RSpec.describe TextAnalyzer::Analyzer do
  let(:input) { "some_file.txt" }
  let(:analyzer) { TextAnalyzer::Analyzer.new([input]) }
  let(:file) { instance_double(File) }

  before(:each) do
    allow(File).to receive(:new).with(input).and_return(file)
    allow(file).to receive(:path).and_return(input)
  end

  describe "#run" do
    before(:each) do
      stub_const("TextAnalyzer::Analyzer::SEQUENCE_SIZE", 3)
      stub_const("TextAnalyzer::Analyzer::RANK_CUTOFF", 1)
      allow(file).to receive(:each_line)
        .and_yield("some! GREAT ..contents")
        .and_yield("(more) good werds")
        .and_yield("s,o,m,e g.r.e.a.t conTENTS")
      allow(STDOUT).to receive(:puts)
    end

    it "analyzes STDIN without starting a new thread" do
      allow(STDIN).to receive(:each_line)
      expect(Thread).not_to receive(:new)
      TextAnalyzer::Analyzer.new(STDIN).run
    end

    it "analyzes a single file input without starting a new thread" do
      expect(Thread).not_to receive(:new)
      analyzer.run
    end

    it "outputs the most common sequences of length SEQUENCE_SIZE in the input" do
      expect(STDOUT).to receive(:puts).with("2 - some great contents")
      analyzer.run
    end

    context "with multiple input files" do
      let(:multi_file_analyzer) { TextAnalyzer::Analyzer.new([input, input]) }
      let(:thread) { instance_double(Thread) }

      before(:each) do
        allow(thread).to receive(:join)
        allow(thread).to receive(:[]).with(:result).and_return({})
      end

      it "analyzes each file in a new thread when given multiple input files" do
        expect(Thread).to receive(:new).and_return(thread).twice
        multi_file_analyzer.run
      end
    end
  end

  describe "#analyze" do
    it "returns an empty result set if the input contains fewer than SEQUENCE_SIZE words" do
      stub_const("TextAnalyzer::Analyzer::SEQUENCE_SIZE", 4)
      allow(file).to receive(:each_line)
        .and_yield(generate_word)
        .and_yield(generate_word)
        .and_yield(generate_word)
      analyzer = TextAnalyzer::Analyzer.new(input)
      expect(analyzer.analyze(file).length).to eq(0)
    end

    it "detects sequences of SEQUENCE_SIZE words across multiple lines" do
      stub_const("TextAnalyzer::Analyzer::SEQUENCE_SIZE", 4)
      allow(file).to receive(:each_line)
        .and_yield(generate_word)
        .and_yield(generate_word)
        .and_yield(generate_word)
        .and_yield(generate_word)
      analyzer = TextAnalyzer::Analyzer.new(input)
      expect(analyzer.analyze(file).length).to eq(1)
    end

    it "detects sequences of SEQUENCE_SIZE words across empty lines" do
      stub_const("TextAnalyzer::Analyzer::SEQUENCE_SIZE", 3)
      allow(file).to receive(:each_line)
        .and_yield(generate_word)
        .and_yield("")
        .and_yield(generate_word)
        .and_yield(generate_word)
      analyzer = TextAnalyzer::Analyzer.new(input)
      expect(analyzer.analyze(file).length).to eq(1)
    end
  end

  describe "#get_most_common" do
    it "returns the top RANK_CUTOFF results keyed and ordered by count" do
      stub_const("TextAnalyzer::Analyzer::RANK_CUTOFF", 3)

      result = {
        ["we", "were", "both"] => 2,
        ["young", "when", "i"] => 5,
        ["first", "saw", "you"] => 1,
        ["i", "close", "my"] => 4,
        ["eyes", "the", "flashback"] => 7,
        ["starts", "im", "standin"] => 6,
      }

      top_3 = {
        7 => ["eyes", "the", "flashback"],
        6 => ["starts", "im", "standin"],
        5 => ["young", "when", "i"],
      }

      expect(analyzer.get_most_common(result)).to eq(top_3)
    end
  end

  describe "#combine_results" do
    it "correctly sums results for common sequences between different result sets" do
      first_result = {
        ["we", "were", "both"] => 2,
        ["young", "when", "i"] => 5,
        ["first", "saw", "you"] => 1,
      }
      second_result = {
        ["i", "close", "my"] => 4,
        ["eyes", "the", "flashback"] => 7,
        ["young", "when", "i"] => 3,
      }

      combined_result = analyzer.combine_results([first_result, second_result])
      expect(combined_result).to include(
        ["young", "when", "i"] => 8,
        ["eyes", "the", "flashback"] => 7,
        ["i", "close", "my"] => 4,
        ["we", "were", "both"] => 2,
        ["first", "saw", "you"] => 1,
      )
    end
  end

  describe "#normalize!" do
    it "ignores punctuation" do
      expect(analyzer.normalize!("(i love sandwiches!!!)")).to eq("i love sandwiches")
    end

    it "resolves upper and lower casing differences" do
      expect(analyzer.normalize!("I LOVE SANDWICHES")).to eq("i love sandwiches")
    end
  end
end
