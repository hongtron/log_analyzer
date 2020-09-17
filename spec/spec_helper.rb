require "bundler/setup"
require "text_analyzer"
require "pry-byebug"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def token_chars
  @token_chars ||= [('a'..'z'), ('A'..'Z'), (0..9)].map(&:to_a).flatten
end

def ignored_chars # not comprehensive
  "\!\@\#\$\%\^\&\*\(\)\;\:\'".chars
end

def word_chars
  @word_chars ||= token_chars + ignored_chars
end

def generate_token
  (1..10).to_a.sample.times.map { |_| token_chars.sample }.join
end

def generate_word
  word = ""
  until (word.chars.to_set - ignored_chars.to_set).length > 0
    word = (1..10).to_a.sample.times.map { |_| word_chars.sample }.join
  end

  word
end

def generate_line(length = nil)
  length ||= (1..10).to_a.sample
  length.times.map { |_| generate_token }.join(" ")
end
