php_legacy::ini { '/etc/php-httpd.ini': }
service { 'httpd': }
package { 'httpd': ensure => installed }
class { 'php_legacy::mod_php5': inifile => '/etc/php-httpd.ini' }
