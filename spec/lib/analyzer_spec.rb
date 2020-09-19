RSpec.describe LogAnalyzer::Analyzer do
  let(:input) { "some_file.txt" }
  let(:analyzer) { LogAnalyzer::Analyzer.new(input) }
  let(:file) { instance_double(File) }
  let(:row) do
    r = instance_double(CSV::Row)
  end

  before(:each) do
    allow(CSV).to receive(:foreach).with(input, anything)
      .and_yield("some! GREAT ..contents")
      .and_yield("(more) good werds")
  end

  describe "#run" do
    before(:each) do
      stub_const("LogAnalyzer::Analyzer::SEQUENCE_SIZE", 3)
      stub_const("LogAnalyzer::Analyzer::RANK_CUTOFF", 1)
      allow(STDOUT).to receive(:puts)
    end

    it "advances the log clock" do
      expect_any_instance_of(LogAnalyzer::LogClock).to receive(:tick)
      analyzer.run
    end
    it "runs the check"
    it "updates the bucket"
    it "starts a new bucket if the current bucket is expired"
  end
end
