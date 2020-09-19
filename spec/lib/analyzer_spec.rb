RSpec.describe LogAnalyzer::Analyzer do
  let(:input) { "some_file.txt" }
  let(:analyzer) { LogAnalyzer::Analyzer.new([input]) }
  let(:file) { instance_double(File) }

  before(:each) do
    allow(File).to receive(:new).with(input).and_return(file)
    allow(file).to receive(:path).and_return(input)
  end

  describe "#run" do
    before(:each) do
      stub_const("LogAnalyzer::Analyzer::SEQUENCE_SIZE", 3)
      stub_const("LogAnalyzer::Analyzer::RANK_CUTOFF", 1)
      allow(file).to receive(:each_line)
        .and_yield("some! GREAT ..contents")
        .and_yield("(more) good werds")
        .and_yield("s,o,m,e g.r.e.a.t conTENTS")
      allow(STDOUT).to receive(:puts)
    end
  end

  describe "#analyze" do
    it "advances the log clock" do
      expect_any_instance_of(LogAnalyzer::LogClock).to receive(:tick)
      analyzer.analyze(input)
    end
    it "runs the check"
    it "updates the bucket"
    it "starts a new bucket if the current bucket is expired"
  end
end
