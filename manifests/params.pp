#
# == Class rethinkdb::params
class rethinkdb::params {
  $command             = 'rethinkdb'
  $config              = '/opt/rethinkdb/rethinkdb.conf'
  $config_template     = 'rethinkdb/rethinkdb.conf.erb'
  
  #rethinkdb config
  $data_dir            = '/opt/rethinkdb/data'
  $log_file            = '/var/log/rethinkdb.log'
  $server_name         = 'guadaleteDB'
  $http_port           = 8080
  $driver_port         = 28015
  $cluster_port        = 29015
  $io_threads          = 64

  $gid                 = 53076
  $group               = 'rethinkgroup'
  $group_ensure        = 'present'
  $package_name        = 'rethinkdb'
  $package_ensure      = 'present'
  
  $service_autorestart = true
  $service_enable      = true
  $service_ensure      = 'present'
  $service_manage      = true
  $service_name        = 'rethinkdb'
  $service_retries     = 999
  $service_startsecs   = 10
  $service_stderr_logfile_keep    = 10
  $service_stderr_logfile_maxsize = '20MB'
  $service_stdout_logfile_keep    = 5
  $service_stdout_logfile_maxsize = '20MB'
  
  $shell               = '/bin/sh'
  $uid                 = 53046
  $user                = 'rethinkuser'
  $user_description    = 'RethinkDB system account'
  $user_ensure         = 'present'
  $user_home           = '/home/rethinkuser'
  $user_manage         = true
  $user_managehome     = true
  $working_dir         = '/opt/rethinkdb'
  case $::osfamily {
    'RedHat': {}

    default: {
      fail("The ${module_name} module is not supported on a ${::osfamily} based system.")
    }
  }
}
