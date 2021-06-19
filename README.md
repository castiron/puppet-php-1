# puppet-php

## Overview

Install PHP packages and configure PHP INI files, for using PHP from the CLI,
the Apache httpd module or FastCGI.

The module is very Red Hat Enterprise Linux focused, as the defaults try to
change everything in ways which are typical for RHEL, but it also works on
Debian based distributions (such as Ubuntu), and support for others should
be easy to add.

* `php_legacy::cli` : Simple class to install PHP's Command Line Interface
* `php_legacy::fpm::daemon` : Simple class to install PHP's FastCGI Process Manager
* `php_legacy::fpm::conf` : PHP FPM pool configuration definition
* `php_legacy::ini` : Definition to create php.ini files
* `php_legacy::mod_php5` : Simple class to install PHP's Apache httpd module
* `php_legacy::module` : Definition to manage separately packaged PHP modules
* `php_legacy::module::ini` : Definition to manage the ini files of separate modules

## Examples

Create `php.ini` files for different uses, but based on the same template :

```puppet
php_legacy::ini { '/etc/php.ini':
  display_errors => 'On',
  memory_limit   => '256M',
}
php_legacy::ini { '/etc/httpd/conf/php.ini':
  mail_add_x_header => 'Off',
  # For the parent directory
  require           => Package['httpd'],
}
```

Install the latest version of the PHP command line interface in your OS's
package manager (e.g. Yum for RHEL):

```puppet
include '::php_legacy::cli'
```

Install version 5.3.3 of the PHP command line interface :

```puppet
class { 'php_legacy::cli': ensure => '5.3.3' }
```

Install the PHP Apache httpd module, using its own php configuration file
(you will need mod_env in apache for this to work) :

```puppet
class { 'php_legacy::mod_php5': inifile => '/etc/httpd/conf/php.ini' }
```

Install PHP modules which don't have any configuration :

```puppet
php_legacy::module { [ 'ldap', 'mcrypt' ]: }
```

Configure PHP modules, which must be installed with php_legacy::module first :

```puppet
php_legacy::module { [ 'pecl-apc', 'xml' ]: }
php_legacy::module::ini { 'pecl-apc':
  settings => {
    'apc.enabled'      => '1',
    'apc.shm_segments' => '1',
    'apc.shm_size'     => '64',
  }
}
php_legacy::module::ini { 'xmlreader': pkgname => 'xml' }
php_legacy::module::ini { 'xmlwriter': ensure => 'absent' }
```

Install PHP FastCGI Process Manager with a single pool to be used with nginx.
Note that we reuse the 'www' name to overwrite the example configuration :

```puppet
include '::php_legacy::fpm::daemon'
php_legacy::fpm::conf { 'www':
  listen  => '127.0.0.1:9001',
  user    => 'nginx',
  # For the user to exist
  require => Package['nginx'],
}
```

Then from the nginx configuration :

```
# PHP FastCGI backend
upstream wwwbackend {
  server 127.0.0.1:9001;
}
# Proxy PHP requests to the FastCGI backend
location ~ \.php$ {
  # Don't bother PHP if the file doesn't exist, return the built in
  # 404 page (this also avoids "No input file specified" error pages)
  if (!-f $request_filename) { return 404; }
  include /etc/nginx/fastcgi.conf;
  fastcgi_pass wwwbackend;
}
# Try to send all non-existing files to the main /index.php
# (typically if you have a PHP framework requiring this)
location @indexphp {
  if (-f $document_root/index.php) { rewrite .* /index.php last; }
}
try_files $uri @indexphp;
```

