# Define: php_legacy::module
#
# Manage optional PHP modules which are separately packaged.
# See also php_legacy::module:ini for optional configuration.
#
# Sample Usage :
#  php_legacy::module { [ 'ldap', 'mcrypt', 'xml' ]: }
#  php_legacy::module { 'odbc': ensure => absent }
#  php_legacy::module { 'pecl-apc': }
#
define php_legacy::module (
  $ensure = installed,
) {

  include '::php_legacy::params'

  # Manage the incorrect named php-apc package under Debians
  if ($title == 'apc') {
    $package = $::php_legacy::params::php_apc_package_name
  } else {
    # Hack to get pkg prefixes to work, i.e. php56-mcrypt title
    $package = $title ? {
      /^php/  => $title,
      default => "${::php_legacy::params::php_package_name}-${title}"
    }
  }

  package { $package:
    ensure => $ensure,
  }

  # Reload FPM if present
  if defined(Class['::php_legacy::fpm::daemon']) and $::php_legacy::fpm::daemon::ensure == 'present' {
    Package[$package] ~> Service[$php_legacy::params::fpm_service_name]
  }

}

