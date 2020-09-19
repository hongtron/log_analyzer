module LogAnalyzer
  class LogParser
    def self.ip(row)
      row.fetch("remotehost")
    end

    def self.epoch_time(row)
      row.fetch("date").to_i
    end

    def self.user(row)
      row.fetch("authuser")
    end

    def self.http_status(row)
      row.fetch("status").to_i
    end

    def self.method(row)
      row.fetch("request").split(" ")[0]
    end

    def self.path(row)
      row.fetch("request").split(" ")[1]
    end

    def self.section(row)
      # 0th element is empty string for leading slash
      path(row).split("/")[1]
    end
  end
end
