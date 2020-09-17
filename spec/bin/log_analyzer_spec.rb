RSpec.describe "bin/log_analyzer" do
  it "accepts arguments as a list of one or more file paths" do
    out = %x[DEBUG=true bin/log_analyzer README.md SPECIFICATION.md]
    expect(out).to match("Analyzing README.md")
    expect(out).to match("Analyzing SPECIFICATION.md")
  end

  it "accepts input on stdin" do
    expect(%x[echo "yes hi hello" | DEBUG=true bin/log_analyzer]).to match("Analyzing STDIN")
  end

  it "displays help text if passed args that are not filenames" do
    expect(%x[bin/log_analyzer --textual-healing]).to match("Usage:")
    expect(%x[bin/log_analyzer fhqwhgads]).to match("Usage:")
  end
end
