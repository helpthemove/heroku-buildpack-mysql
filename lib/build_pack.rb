require_relative "build_pack/installer"
require_relative "build_pack/downloader"
require_relative "build_pack/logger"

module BuildPack
  PACKAGES = [
    {
      package: 'mysql-client-core',
      regex: /.*(mysql-client-core-5\.7_5\.7\.\d\d-0ubuntu0\.18\.\d\d\.\d_amd64.deb).*/,
      binaries: %w[mysql]
    },
    {
      package: 'mysql-client',
      regex: /.*(mysql-client-5\.7_5\.7\.\d\d-0ubuntu0\.18\.\d\d\.\d_amd64.deb).*/,
      binaries: %w[mysqldump]
    }
  ]

  def self.run(build_dir, cache_dir)
    PACKAGES.each do |config|
      package, regex, binaries = config.values_at(:package, :regex, :binaries)
      Installer.install(
        build_dir: build_dir,
        cache_dir: cache_dir,
        package: package,
        package_regex: regex,
        binaries: binaries
      )
    end
  end
end
