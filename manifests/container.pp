define docker_systemd::container (
  $ensure           = running,
  $enable           = true,
  $image            = undef,
  $pull_image       = false,
  $command          = undef,
  $depends          = undef,
  $volume           = undef,
  $volumes_from     = undef,
  $link             = undef,
  $publish          = undef,
  $entrypoint       = undef,
  $env              = undef,
  $env_file         = undef,
  $systemd_env_file = undef,
  $hostname         = undef,
  $privileged       = undef,
) {

  include ::docker_systemd

  if $image {
    $image_arg = $image
  } else {
    $image_arg = $title
  }

  $service_name = "docker-${title}.service"
  $docker_run_options = build_docker_run_options({
    link         => $link,
    name         => $title,
    privileged   => $privileged,
    publish      => $publish,
    volume       => $volume,
    volumes_from => $volumes_from,
    entrypoint   => $entrypoint,
    env          => $env,
    env_file     => $env_file,
    hostname     => $hostname,
  })

  file { "/etc/systemd/system/${service_name}":
    ensure  => present,
    content => template('docker_systemd/etc/systemd/system/run-container.service.erb'),
    notify  => Exec['systemctl-daemon-reload'],
  }

  ~>
  service { $service_name:
    ensure   => $ensure,
    enable   => $enable,
    provider => systemd,
  }

}
