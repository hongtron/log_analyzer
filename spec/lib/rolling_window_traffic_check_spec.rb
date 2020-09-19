RSpec.describe LogAnalyzer::RollingWindowTrafficCheck do
  let(:clock) { LogAnalyzer::LogClock.new }
  let(:threshold) { 2 }
  let(:check) { LogAnalyzer::RollingWindowTrafficCheck.new(clock, threshold) }

  describe "#record_hit_and_perform_check!" do
    it "alerts if threshold is exceeded" do

    end

    it "does not alert again if already triggered"

    it "recovers when traffic falls below threshold"
  end
end
