# == Class rethinkdb::install
#
class rethinkdb::install inherits rethinkdb {

  yumrepo { 'RethinkDB':
    name     => 'RethinkDB',
    baseurl  => 'http://download.rethinkdb.com/centos/6/x86_64/',
    enabled  => 1,
    gpgcheck => 0
  }

  package { 'rethinkdb':
    ensure  => $package_ensure,
    name    => $package_name,
    require => Yumrepo['RethinkDB']
  }
  
  file { $working_dir:
    ensure       => directory,
    owner        => $user,
    group        => $group,
    mode         => '0750',
    recurse      => true,
    recurselimit => 0,
  }

  
}
