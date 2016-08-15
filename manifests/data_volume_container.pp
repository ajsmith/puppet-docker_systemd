define docker_systemd::data_volume_container (
  $image            = undef,
  $pull_image       = false,
  $systemd_env_file = undef,
  $volume           = undef,
  $systemd_depends  = undef,
) {

  include ::docker_systemd

  $service_name = "docker-${title}.service"
  $docker_run_options = build_docker_run_options({
    name       => $title,
    volume     => $volume,
    entrypoint => '/bin/true',
    })

  file { "/etc/systemd/system/${service_name}":
    ensure  => present,
    content => template('docker_systemd/etc/systemd/system/data-container.service.erb'),
    notify  => Exec['systemctl-daemon-reload'],
  }

  ~>
  service { $service_name:
    enable   => true,
    provider => systemd,
  }

}
