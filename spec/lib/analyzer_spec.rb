RSpec.describe LogAnalyzer::Analyzer do
  let(:input) { "some_file.txt" }
  let(:alert_threshold) { 10 }
  let(:analyzer) { LogAnalyzer::Analyzer.new(input, alert_threshold) }
  let(:file) { instance_double(File) }
  let(:row) { instance_double(CSV::Row) }

  before(:each) do
    allow(CSV).to receive(:foreach).with(input, anything).and_yield(row)
    allow(row).to receive(:fetch).and_return("some value")
  end

  describe "#run" do
    before(:each) do
      allow(STDOUT).to receive(:puts) # don't pollute test output
    end

    it "advances the log clock" do
      expect_any_instance_of(LogAnalyzer::LogClock).to receive(:tick)
      analyzer.run
    end

    it "runs the check" do
      expect_any_instance_of(LogAnalyzer::RollingWindowTrafficCheck).to receive(:record_hit_and_perform_check!)
      analyzer.run
    end

    it "updates the bucket" do
      expect_any_instance_of(LogAnalyzer::Bucket).to receive(:ingest)
      analyzer.run
    end

    context "when current bucket is expired" do
      let(:new_bucket) { instance_double(LogAnalyzer::Bucket) }
      before(:each) do
        allow(analyzer.bucket).to receive(:expired?).and_return(true)
        allow(new_bucket).to receive(:ingest)
        allow(new_bucket).to receive(:start_time).and_return(0)
        allow(new_bucket).to receive(:end_time).and_return(1)
      end

      it "starts a new bucket" do
        expect(LogAnalyzer::Bucket).to receive(:new).and_return(new_bucket)
        expect(analyzer.bucket).not_to eq(new_bucket)
        analyzer.run
        expect(analyzer.bucket).to eq(new_bucket)
      end

      it "summarizes the expired bucket" do
        expect(analyzer.bucket).to receive(:summarize)
        analyzer.run
      end
    end
  end
end
