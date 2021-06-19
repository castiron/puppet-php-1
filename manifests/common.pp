# Class: php_legacy::common
#
# Class to avoid duplicate definitions for the php-common package, not meant to
# be used from outside the php module's own classes and definitions.
#
# We can't use a virtual resource, since we have no central place to put it.
#
class php_legacy::common (
  $common_package_name = $::php_legacy::params::common_package_name,
) inherits ::php_legacy::params {
  package { $common_package_name: ensure => 'installed' }
}
