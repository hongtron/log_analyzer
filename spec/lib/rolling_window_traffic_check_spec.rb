RSpec.describe LogAnalyzer::RollingWindowTrafficCheck do
  let(:clock) { LogAnalyzer::LogClock.new }
  let(:threshold) { 2 }
  let(:check) { LogAnalyzer::RollingWindowTrafficCheck.new(clock, threshold) }
  let(:output) { File.open(File::NULL, "w") }

  before(:each) do
    clock.tick(1)
    stub_const("LogAnalyzer::RollingWindowTrafficCheck::WINDOW_SIZE", 1)
  end

  describe "#record_hit_and_perform_check!" do
    it "alerts using the current log time if threshold is exceeded" do
      expect(check.triggered?).to be(false)
      check.record_hit_and_perform_check!(output, 1)
      expect(check.triggered?).to be(false)

      expect(output).to receive(:puts).with(/generated an alert.*triggered at time #{clock.current_time}/)
      check.record_hit_and_perform_check!(output, 1)
      expect(check.triggered?).to be(true)
    end

    it "rolls metrics off the back of the window when they expire" do
      check.record_hit_and_perform_check!(output, 1)
      hit_count = 0
      current_hits = check.hits
      while current_hits do
        hit_count += current_hits.count
        current_hits = current_hits.next
      end

      expect(hit_count).to eq(1)

      clock.tick(2)
      check._roll_window!

      hit_count = 0
      current_hits = check.hits
      while current_hits do
        hit_count += current_hits.count
        current_hits = current_hits.next
      end

      # at time 2, window_start is 1, the hit we recorded is still around
      expect(hit_count).to eq(1)

      clock.tick(3)
      check._roll_window!

      hit_count = 0
      current_hits = check.hits
      while current_hits do
        hit_count += current_hits.count
        current_hits = current_hits.next
      end

      # at time 3, window_start is 2, so the hit should have rolled off
      expect(hit_count).to eq(0)
    end

    context "when alert is already triggered" do
      before(:each) do
        check.record_hit_and_perform_check!(output, 1)
        check.record_hit_and_perform_check!(output, 1)
        expect(check.triggered?).to be(true)
      end

      it "does not alert again if already triggered" do
        expect(output).not_to receive(:puts).with(/generated an alert/)
        check.record_hit_and_perform_check!(output, 1)
      end

      it "recovers when traffic falls below threshold" do
        clock.tick(3)
        check.record_hit_and_perform_check!(output, -1)
        # at time 3, window_start is 2, and there shouldn't be any hits logged
        expect(check.triggered?).to be(false)
      end
    end
  end
end
