define docker_systemd::container (
  $ensure       = running,
  $enable       = true,
  $image        = undef,
  $command      = undef,
  $depends      = undef,
  $volume       = undef,
  $volumes_from = undef,
  $link         = undef,
  $publish      = undef,
  $entrypoint   = undef,
  $env          = undef,
  $env_file     = undef,
) {

  $image_arg = $image ? { undef => $title, default => $image }

  $service_name = "docker-${title}.service"
  $docker_run_options = build_docker_run_options({
    link         => $link,
    name         => $title,
    publish      => $publish,
    volume       => $volume,
    volumes_from => $volumes_from,
    entrypoint   => $entrypoint,
    env          => $env,
    env_file     => $env_file,
  })

  file { "/etc/docker-${title}.env":
    ensure  => present,
    content => template('docker_systemd/etc/run-container.env.erb'),
  }->
  file { "/etc/systemd/system/${service_name}":
    ensure  => present,
    content => template('docker_systemd/etc/systemd/system/run-container.service.erb'),
  }~>
  service { $service_name:
    ensure   => $ensure,
    enable   => $enable,
    provider => systemd,
  }
}
