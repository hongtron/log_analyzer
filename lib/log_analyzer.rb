require "fileutils"
require "logger"
require "csv"

require "log_analyzer/analyzer"
require "log_analyzer/bucket"
require "log_analyzer/log_clock"
require "log_analyzer/rolling_window_traffic_check"
require "log_analyzer/log_parser"
require "log_analyzer/timeseries_data_point"
require "log_analyzer/version"

module LogAnalyzer
  LOGGER = Logger.new(STDOUT)
  DEFAULT_ALERT_THRESHOLD = 10 # requests/sec

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
