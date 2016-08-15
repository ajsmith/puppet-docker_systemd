require 'spec_helper'

describe 'docker_systemd::data_volume_container' do

  context 'with defaults for all parameters' do
    let(:title) { 'httpd-data' }
    let(:params) {
      {
        :image   => 'httpd',
        :volume  => ['/var/data'],
        :systemd_depends => ['network.target'],
      }
    }

    it {
      should contain_file(
               '/etc/systemd/system/docker-httpd-data.service'
             ).that_notifies('Exec[systemctl-daemon-reload]')

      should contain_file('/etc/systemd/system/docker-httpd-data.service').with(
                  {
                    'ensure'  => 'present',
                    'content' => <<-EOF\
[Unit]
Description=Docker Data Container for httpd-data
Requires=docker.service network.target
After=docker.service network.target

[Service]
Type=oneshot
Restart=no
RemainAfterExit=yes


ExecStart=-/usr/bin/docker create \\
    --name httpd-data \\
    --volume /var/data \\
    --entrypoint /bin/true \\
    httpd
ExecStop=/usr/bin/docker stop httpd-data

[Install]
WantedBy=multi-user.target
EOF
                  })
    }

    it { should contain_service('docker-httpd-data.service').with(
                  {
                    'enable'   => 'true',
                    'provider' => 'systemd'
                  })
    }
  end

  context 'with all parameters configured' do
    let(:title) { 'httpd-data' }
    let(:params) {
      {
        :image            => '$IMAGE',
        :pull_image       => 'true',
        :systemd_env_file => '/etc/sysconfig/docker-httpd-data.env',
      }
    }

    it {
      should contain_file(
               '/etc/systemd/system/docker-httpd-data.service'
             ).that_notifies('Exec[systemctl-daemon-reload]')

      should contain_file('/etc/systemd/system/docker-httpd-data.service').with(
                  {
                    'ensure'  => 'present',
                    'content' => <<-EOF\
[Unit]
Description=Docker Data Container for httpd-data
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
Restart=no
RemainAfterExit=yes
EnvironmentFile=/etc/sysconfig/docker-httpd-data.env
ExecStartPre=/usr/bin/docker pull $IMAGE
ExecStart=-/usr/bin/docker create \\
    --name httpd-data \\
    --entrypoint /bin/true \\
    $IMAGE
ExecStop=/usr/bin/docker stop httpd-data

[Install]
WantedBy=multi-user.target
EOF
                  })
    }

    it { should contain_service('docker-httpd-data.service').with(
                  {
                    'enable'   => 'true',
                    'provider' => 'systemd'
                  })
    }
  end
end
