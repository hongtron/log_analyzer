RSpec.describe LogAnalyzer::Analyzer do
  let(:input) { "some_file.txt" }
  let(:alert_threshold) { 10 }
  let(:analyzer) { LogAnalyzer::Analyzer.new(input, alert_threshold) }
  let(:file) { instance_double(File) }
  let(:row) { instance_double(CSV::Row) }

  before(:each) do
    allow(CSV).to receive(:foreach).with(input, anything).and_yield(row).and_yield(row)
    allow(row).to receive(:fetch).and_return("some value")
  end

  describe "#run" do
    before(:each) do
      allow(STDOUT).to receive(:puts) # don't pollute test output
    end

    it "advances the log clock" do
      expect_any_instance_of(LogAnalyzer::LogClock).to receive(:tick).at_least(1).time
      analyzer.run
    end

    it "runs the check" do
      expect_any_instance_of(LogAnalyzer::RollingWindowTrafficCheck).to receive(:record_hit_and_perform_check!).at_least(1).time
      analyzer.run
    end

    it "updates the bucket" do
      expect_any_instance_of(LogAnalyzer::Bucket).to receive(:ingest).at_least(1).time
      analyzer.run
    end

    context "when current bucket is expired" do
      let(:expired_bucket) { instance_double(LogAnalyzer::Bucket) }
      let(:new_bucket) { instance_double(LogAnalyzer::Bucket) }
      before(:each) do
        allow(LogAnalyzer::Bucket).to receive(:new).and_return(expired_bucket, new_bucket)
        allow(expired_bucket).to receive(:expired?).and_return(true)
        allow(expired_bucket).to receive(:ingest)
        allow(expired_bucket).to receive(:start_time).and_return(-2)
        allow(expired_bucket).to receive(:end_time).and_return(-1)
        allow(new_bucket).to receive(:summarize)
        allow(new_bucket).to receive(:ingest)
        allow(new_bucket).to receive(:start_time).and_return(0)
        allow(new_bucket).to receive(:end_time).and_return(1)
        allow(new_bucket).to receive(:expired?).and_return(false)
      end

      it "starts a new bucket and summarizes the expired bucket" do
        expect(expired_bucket).to receive(:summarize)
        analyzer.run
        expect(analyzer.bucket).to eq(new_bucket)
      end
    end
  end
end
