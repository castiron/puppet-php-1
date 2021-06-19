# Class: php_legacy::cli
#
# Command Line Interface PHP. Useful for console scripts, cron jobs etc.
# To customize the behavior of the php binary, see php_legacy::ini.
#
# Sample Usage:
#  include php_legacy::cli
#
class php_legacy::cli (
  $ensure           = 'installed',
  $inifile          = $php_legacy::params::cli_inifile,
  $cli_package_name = $::php_legacy::params::cli_package_name,
) inherits ::php_legacy::params {
  package { $cli_package_name:
    ensure  => $ensure,
    require => File[$inifile],
  }
}

