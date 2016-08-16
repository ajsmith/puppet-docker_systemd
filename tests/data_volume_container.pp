# Test a data volume container service.
docker_systemd::data_volume_container { 'grafana-data':
  image      => 'ajsmith/grafana',
  pull_image => true,
}
