RSpec.describe LogAnalyzer::Bucket do
  let(:clock) { LogAnalyzer::LogClock.new }
  let(:bucket) { LogAnalyzer::Bucket.new(clock, 5) }
  let(:row) { instance_double(CSV::Row) }

  describe "most_trafficked_sections" do
    it "returns the top STAT_RANK_CUTOFF trafficked sections keyed by hits in descending order" do
      section_responses = %w[reports api api reports api]
      allow(LogAnalyzer::LogParser).to receive(:section).with(row).and_return(*section_responses)
      section_responses.length.times { bucket.ingest(row) }

      expect(bucket.most_trafficked_sections).to eq(3 => "api", 2 => "reports")
    end
  end
end
