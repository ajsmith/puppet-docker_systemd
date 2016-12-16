define docker_systemd::container (
  # General options
  $ensure             = running,
  $enable             = true,
  $image              = undef,
  $depends            = undef,
  $pull_image         = false,

  # docker-run options
  $command            = undef,
  $entrypoint         = undef,
  $env                = undef,
  $env_file           = undef,
  $hostname           = undef,
  $link               = undef,
  $log_driver         = undef,
  $log_opt            = undef,
  $memory             = undef,
  $memory_reservation = undef,
  $memory_swap        = undef,
  $memory_swappiness  = undef,
  $net                = undef,
  $privileged         = undef,
  $publish            = undef,
  $volume             = undef,
  $volumes_from       = undef,

  # systemd options
  $systemd_depends  = undef,
  $systemd_env_file = undef,
) {

  include ::docker_systemd

  if $image {
    $image_arg = $image
  } else {
    $image_arg = $title
  }

  $service_name = "docker-${title}.service"
  $docker_run_options = build_docker_run_options({
    entrypoint         => $entrypoint,
    env                => $env,
    env_file           => $env_file,
    hostname           => $hostname,
    link               => $link,
    log_driver         => $log_driver,
    log_opt            => $log_opt,
    memory             => $memory,
    memory_reservation => $memory_reservation,
    memory_swap        => $memory_swap,
    memory_swappiness  => $memory_swappiness,
    name               => $title,
    net                => $net,
    privileged         => $privileged,
    publish            => $publish,
    volume             => $volume,
    volumes_from       => $volumes_from,
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
