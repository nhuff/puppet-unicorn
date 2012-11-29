define unicorn::instance(
  $basedir,
  $config_file = '',
  $pid_file = '',
  $logdir = '',
  $worker_processes = $::processorcount,
  $socket_path = false,
  $socket_backlog = 64,
  $port = false,
  $tcp_nopush = true,
  $timeout_secs = 60,
  $preload_app = false,
  $rolling_restarts = true,
  $rolling_restarts_sleep = 1,
  $debug_base_port = false,
  $require_extras = [],
  $before_exec = [],
  $before_fork_extras = [],
  $after_fork_extras = [],
  $command = 'unicorn',
  $env = 'production',
  $uid = 'root',
  $gid = 'root',
) {
  include unicorn

  $r_pidfile = $pidfile ? {
    ''      => "${basedir}/${title}_unicorn.pid",
    default => $pidfile,
  }

  $r_logdir = $logdir ? {
    ''      => $basedir,
    default => $logdir,
  }

  $r_config_file = $config_file ? {
    ''      => "${basedir}/unicorn.conf",
    default => $config_file,
  }

  file { $r_config_file:
      mode    => 644,
      owner   => $uid,
      group   => $gid,
      content => template('unicorn/unicorn.conf.erb');
  }

  service { "${name}_unicorn":
      provider  => 'base',
      start     => "${command} -E ${env} -c ${r_config_file} -D",
      stop      => "kill `cat ${r_pidfile}`",
      restart   => "kill -s USR2 `cat ${r_pidfile}`",
      status    => "ps -o pid= -o comm= -p `cat ${r_pidfile}`",
      ensure    => 'running',
      subscribe => File[$r_config_file],
      require   => Package['rubygem-unicorn'],
  }
}
