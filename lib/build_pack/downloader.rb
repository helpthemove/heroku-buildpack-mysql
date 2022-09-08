require 'net/http'

module BuildPack
  class Downloader
    MYSQL_BASE_URL = "http://security.ubuntu.com/ubuntu/pool/main/m/mysql-5.7/"

    class << self
      def download_latest_client_to(package_regex, path)
        Logger.log_header("Downloading MySQL Client package")

        client = most_recent_client(package_regex)

        if client.empty?
          Logger.log("No suitable clients available")
          return
        end

        Logger.log("Selecting: #{client}")

        File.open(path, 'w+').write(Net::HTTP.get(URI.parse("#{MYSQL_BASE_URL}#{client}")))
      end

      def most_recent_client(package_regex)
        Logger.log("Looking for clients at: #{MYSQL_BASE_URL}")

        response = Net::HTTP.get(URI.parse("#{MYSQL_BASE_URL}"))

        Logger.log("available clients:")
        most_recent = ""
        response.lines.each do |line|
          if package_regex =~ line
            Logger.log("#{$1}")
            most_recent = $1 if $1 > most_recent
          end
        end

        most_recent
      end
    end
  end
end
