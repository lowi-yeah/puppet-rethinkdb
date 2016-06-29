# == Class rethinkdb::config
#
class rethinkdb::config inherits rethinkdb {

  file { $log_file:
    ensure  => file,
    owner   => $user,
    group   => $group,
    mode    => '0644',
    require => Class['rethinkdb::install'],
  }

  file { $config:
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template($config_template),
    require => Class['rethinkdb::install']
  }
}
