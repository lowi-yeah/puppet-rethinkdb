class rethinkdb (
  $command             = $rethinkdb::params::command,
  $config              = $rethinkdb::params::config,
  $config_template     = $rethinkdb::params::config_template,

  $data_dir            = $rethinkdb::params::data_dir,
  $log_file            = $rethinkdb::params::log_file,
  $server_name         = $rethinkdb::params::server_name,
  $http_port           = $rethinkdb::params::http_port,
  $driver_port         = $rethinkdb::params::driver_port,
  $cluster_port        = $rethinkdb::params::cluster_port,
  $io_threads          = $rethinkdb::params::io_threads,

  $gid                 = $rethinkdb::params::gid,
  $group               = $rethinkdb::params::group,
  $group_ensure        = $rethinkdb::params::group_ensure,
  $package_name        = $rethinkdb::params::package_name,
  $package_ensure      = $rethinkdb::params::package_ensure,

  $service_autorestart = hiera('rethinkdb::service_autorestart', $rethinkdb::params::service_autorestart),
  $service_enable      = hiera('rethinkdb::service_enable', $rethinkdb::params::service_enable),
  $service_ensure      = $rethinkdb::params::service_ensure,
  $service_manage      = hiera('rethinkdb::service_manage', $rethinkdb::params::service_manage),
  $service_name        = $rethinkdb::params::service_name,
  $service_retries     = $rethinkdb::params::service_retries,
  $service_startsecs   = $rethinkdb::params::service_startsecs,
  $service_stderr_logfile_keep    = $rethinkdb::params::service_stderr_logfile_keep,
  $service_stderr_logfile_maxsize = $rethinkdb::params::service_stderr_logfile_maxsize,
  $service_stdout_logfile_keep    = $rethinkdb::params::service_stdout_logfile_keep,
  $service_stdout_logfile_maxsize = $rethinkdb::params::service_stdout_logfile_maxsize,
  
  $shell               = $rethinkdb::params::shell,
  $uid                 = $rethinkdb::params::uid,
  $user                = $rethinkdb::params::user,
  $user_description    = $rethinkdb::params::user_description,
  $user_ensure         = $rethinkdb::params::user_ensure,
  $user_home           = $rethinkdb::params::user_home,
  $user_manage         = hiera('rethinkdb::user_manage', $rethinkdb::params::user_manage),
  $user_managehome     = hiera('rethinkdb::user_managehome', $rethinkdb::params::user_managehome),
  $working_dir         = $rethinkdb::params::working_dir,

) inherits rethinkdb::params {

  validate_string($command)
  validate_absolute_path($config)
  validate_string($config_template)

  validate_absolute_path($data_dir)            
  validate_absolute_path($log_file)            
  validate_string($server_name)                
  if !is_integer($http_port) { fail('The $http_port parameter must be an integer number') }
  if !is_integer($driver_port) { fail('The $driver_port parameter must be an integer number') }
  if !is_integer($cluster_port) { fail('The $cluster_port parameter must be an integer number') }
  if !is_integer($io_threads) { fail('The $io_threads parameter must be an integer number') }

  if !is_integer($gid) { fail('The $gid parameter must be an integer number') }
  validate_string($group)
  validate_string($group_ensure)
  validate_string($package_ensure)
  validate_string($package_name)

  validate_bool($service_autorestart)
  validate_bool($service_enable)
  validate_string($service_ensure)
  validate_bool($service_manage)
  validate_string($service_name)
  if !is_integer($service_retries) { fail('The $service_retries parameter must be an integer number') }
  if !is_integer($service_startsecs) { fail('The $service_startsecs parameter must be an integer number') }
  if !is_integer($service_stderr_logfile_keep) {fail('The $service_stderr_logfile_keep parameter must be an integer number')}
  validate_string($service_stderr_logfile_maxsize)
  if !is_integer($service_stdout_logfile_keep) { fail('The $service_stdout_logfile_keep parameter must be an integer number')}
  validate_string($service_stdout_logfile_maxsize)
  
  validate_absolute_path($shell)
  if !is_integer($uid) { fail('The $uid parameter must be an integer number') }
  validate_string($user)
  validate_string($user_description)
  validate_string($user_ensure)
  validate_absolute_path($user_home)
  validate_bool($user_manage)
  validate_bool($user_managehome)
  validate_absolute_path($working_dir)

  include '::rethinkdb::users'
  include '::rethinkdb::install'
  include '::rethinkdb::config'
  include '::rethinkdb::service'

  # Anchor this as per #8040 - this ensures that classes won't float off and
  # mess everything up. You can read about this at:
  # http://docs.puppetlabs.com/puppet/2.7/reference/lang_containment.html#known-issues
  anchor { 'rethinkdb::begin': }
  anchor { 'rethinkdb::end': }

  Anchor['rethinkdb::begin']
  -> Class['::rethinkdb::users']
  -> Class['::rethinkdb::install']
  -> Class['::rethinkdb::config']
  ~> Class['::rethinkdb::service']
  -> Anchor['rethinkdb::end']
}
