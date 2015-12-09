
class frigg_worker (
  $dispatcher_token,
  $dispatcher_url,
  $hq_token,
  $hq_url,
  $mode,
  $slack_url,
  $sentry_dsn,
  $num_workers = $::processorcount,
  $path = '/opt/frigg-worker',
  $docker_images = ['frigg/frigg-test-base', 'frigg/frigg-test-dind'],
  $user = 'root'
) {

  class { 'docker':
    dns            => '8.8.8.8',
    storage_driver => 'devicemapper',
  }

  ->

  frigg_worker::docker_image { $docker_images: }

  exec { $path:
    command => "/usr/bin/virtualenv $path -p $(which python3)",
    creates => "$path/bin",
    user    => $user,
    require => [Class['docker']]
  }

  ->

  exec { "$path/bin/pip install -U pip":
    user => $user
  }

  ->

  exec { "$path/bin/pip install -U requests frigg-worker frigg-settings frigg-test-discovery frigg-coverage":
    user => $user
  }

  ->

  service { 'frigg-worker':
    ensure  => 'running',
    enable  => true,
    require => [File['/etc/init.d/frigg-worker']];
  }

  file { '/etc/init.d/frigg-worker':
    notify  => Service['frigg-worker'],
    path    => '/etc/init.d/frigg-worker',
    owner   => root,
    group   => root,
    mode    => '0751',
    content => template('frigg_worker/init.erb');
  }

}
