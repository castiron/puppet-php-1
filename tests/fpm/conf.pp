include php_legacy::fpm::daemon
php_legacy::fpm::conf { 'www': ensure => absent }
php_legacy::fpm::conf { 'customer1':
    listen => '127.0.0.1:9001',
    user   => 'customer1',
}
