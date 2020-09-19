RSpec.describe "bin/log_analyzer" do
  it "accepts a file path argument" do
    expect(%x[DEBUG=true bin/log_analyzer README.md]).to match("Analyzing README.md")
  end

  it "accepts input on stdin" do
    expect(%x[echo "yes hi hello" | DEBUG=true bin/log_analyzer]).to match("Analyzing STDIN")
  end

  it "displays help text if passed args that are not filenames" do
    expect(%x[bin/log_analyzer --cheese]).to match("Usage:")
    expect(%x[bin/log_analyzer fhqwhgads]).to match("Usage:")
  end
end
