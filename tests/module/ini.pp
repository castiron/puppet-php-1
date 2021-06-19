php_legacy::module { [ 'pecl-apc', 'xml' ]: }
php_legacy::module::ini { 'pecl-apc':
    settings => {
        'apc.enabled'      => '1',
        'apc.shm_segments' => '1',
        'apc.shm_size'     => '64',
    }
}
php_legacy::module::ini { 'xmlreader': pkgname => 'xml' }
