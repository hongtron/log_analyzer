require_relative 'lib/text_analyzer/version'

Gem::Specification.new do |spec|
  spec.name          = "text_analyzer"
  spec.version       = TextAnalyzer::VERSION
  spec.authors       = ["ali hong"]
  spec.email         = ["hi@alihong.net"]

  spec.summary       = %q{Solution to NewRelic coding challenge.}
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
