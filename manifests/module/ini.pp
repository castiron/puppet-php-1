# Define: php_legacy::module::ini
#
# Configuration for optional PHP modules which are separately packaged.
# See also php_legacy::module for package installation.
#
# Sample Usage :
#  php_legacy::module::ini { 'xmlreader': pkgname => 'xml' }
#  php_legacy::module::ini { 'pecl-apc':
#      settings => {
#          'apc.enabled'      => '1',
#          'apc.shm_segments' => '1',
#          'apc.shm_size'     => '64',
#      }
#  }
#  php_legacy::module::ini { 'xmlwriter': ensure => absent }
#
define php_legacy::module::ini (
  $ensure   = undef,
  $pkgname  = false,
  $prefix   = undef,
  $settings = {},
  $zend     = false,
) {

  include '::php_legacy::params'

  # Strip 'pecl-*' prefix is present, since .ini files don't have it
  $modname = regsubst($title , '^pecl-', '', 'G')

  # Handle naming issue of php-apc package on Debian
  if ($modname == 'apc' and $pkgname == false) {
    # Package name
    $ospkgname = $::php_legacy::params::php_apc_package_name
  } else {
    # Package name
    $ospkgname = $pkgname ? {
      /^php/  => $pkgname,
      false   => "${::php_legacy::params::php_package_name}-${title}",
      default => "${::php_legacy::params::php_package_name}-${pkgname}",
    }
  }

  # INI configuration file
  if $prefix {
    $inifile = "${::php_legacy::params::php_conf_dir}/${prefix}-${modname}.ini"
  } else {
    $inifile = "${::php_legacy::params::php_conf_dir}/${modname}.ini"
  }
  if $ensure == 'absent' {
    file { $inifile:
      ensure => absent,
    }
  } else {
    file { $inifile:
      ensure  => $ensure,
      require => Package[$ospkgname],
      content => template('php_legacy/module.ini.erb'),
    }
  }

  # Reload FPM if present
  if defined(Class['::php_legacy::fpm::daemon']) and $::php_legacy::fpm::daemon::ensure == 'present' {
    File[$inifile] ~> Service[$php_legacy::params::fpm_service_name]
  }

}
