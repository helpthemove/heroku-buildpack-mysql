require 'fileutils'

module BuildPack
  class Installer
    class << self

      def install(build_dir:, cache_dir:, package:, package_regex:, binaries:)
        @package = package
        @binaries = binaries
        init_paths(build_dir, cache_dir)
        make_dirs
        Downloader.download_latest_client_to(package_regex, @mysql_pkg) unless cached?
        if client_exists?
          install_client and cleanup
        else
          fail_install
        end
      end

      private

      def init_paths(build_dir, cache_dir)
        @bin_path = "#{build_dir}/bin"
        @tmp_path = "#{build_dir}/tmp"
        @mysql_path = "#{@tmp_path}/#{@package}"
        @mysql_binaries = "#{@mysql_path}/usr/bin"
        @mysql_pkg = "#{cache_dir}/#{@package}.deb"
      end

      def make_dirs
        FileUtils.mkdir_p(@bin_path)
        FileUtils.mkdir_p(@tmp_path)
      end

      def cached?
        if exists = client_exists?
          Logger.log_header("Using MySQL Client package from cache")
        end

        exists
      end

      def client_exists?
        File.exist?(@mysql_pkg)
      end

      def install_client
        run_command_with_message(command: "dpkg -x #{@mysql_pkg} #{@mysql_path}", message: "Installing MySQL Client")
        fix_perms_and_mv_binaries
      end

      def run_command_with_message(command:, message:)
        Logger.log_header("#{message}")
        Logger.log("#{command}")
        output = `#{command}`
        puts output
      end

      def fix_perms_and_mv_binaries
        Logger.log('Contents of mysql bin dir:')
        Logger.log(`ls #{@mysql_binaries}`)

        @binaries.each do |binary|
          path = Dir.glob("#{@mysql_binaries}/#{binary}")
          FileUtils.chmod("u=wrx", path)
          FileUtils.mv(path, @bin_path)
        end
      end

      def cleanup
        Logger.log_header("Cleaning up")
        FileUtils.remove_dir(@mysql_path)
      end

      def fail_install
        Logger.log_header("Failing mysql client installation as no suitable clients were found")
        exit 1
      end
    end
  end
end
