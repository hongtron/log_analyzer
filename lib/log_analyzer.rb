require "fileutils"
require "logger"

require "log_analyzer/analyzer"
require "log_analyzer/bucket"
require "log_analyzer/window"
require "log_analyzer/version"

module LogAnalyzer
  LOGGER = Logger.new(STDOUT)

  class << self
    LOGGER.level = Logger::WARN

    def debug?
      ENV["DEBUG"] == "true"
    end
  end
end

if LogAnalyzer.debug?
  require "pry-byebug"
  LogAnalyzer::LOGGER.level = Logger::DEBUG
end
