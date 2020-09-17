require "fileutils"
require "logger"

require "text_analyzer/analyzer"
require "text_analyzer/version"

module TextAnalyzer
  LOGGER = Logger.new(STDOUT)

  class << self
    LOGGER.level = Logger::WARN

    def debug?
      ENV["DEBUG"] == "true"
    end
  end
end

if TextAnalyzer.debug?
  require "pry-byebug"
  Thread.abort_on_exception = true
  TextAnalyzer::LOGGER.level = Logger::DEBUG
end
