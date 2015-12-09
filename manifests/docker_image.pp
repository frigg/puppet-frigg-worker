
define frigg_worker::docker_image (
  $ensure = 'latest',
  $tag    = 'latest',
) {
  $command = 'docker pull $title:$tag'

  require docker

  docker::image { $title:
    ensure => $ensure
  }

  cron { $title:
    command => $command,
    user    => root,
    hour    => '*/1',
    require => Docker::Image[$title];
  }
}
