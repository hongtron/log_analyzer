RSpec.describe LogAnalyzer::LogClock do
  let(:clock) { LogAnalyzer::LogClock.new }
  let(:row) { instance_double(CSV::Row) }


  describe "#tick" do
    context "when called with a time that is greater than the current time" do
      before(:each) do
        allow(LogAnalyzer::LogParser).to receive(:epoch_time).with(row).and_return(clock.current_time + 1)
      end

      it "advances the time" do
        expect { clock.tick(row) }.to change { clock.current_time }.by(1)
      end
    end

    context "when called with a time that is less than the current time" do
      before(:each) do
        allow(LogAnalyzer::LogParser).to receive(:epoch_time).with(row).and_return(clock.current_time - 1)
      end

      it "does not advance the time" do
        expect { clock.tick(row) }.not_to change { clock.current_time }
      end
    end
  end
end
