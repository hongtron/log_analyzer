RSpec.describe LogAnalyzer::LogClock do
  let(:clock) { LogAnalyzer::LogClock.new }

  describe "#tick" do
    context "when called with a time that is greater than the current time" do
      let(:tick_time) { clock.current_time + 1 }

      it "advances the time" do
        expect { clock.tick(tick_time) }.to change { clock.current_time }.by(1)
      end
    end

    context "when called with a time that is less than the current time" do
      let(:tick_time) { clock.current_time - 1 }

      it "does not advance the time" do
        expect { clock.tick(tick_time) }.not_to change { clock.current_time }
      end
    end
  end
end
