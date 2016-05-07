require 'spec_helper'

describe 'docker_systemd::container' do
  context 'with defaults for all parameters' do
    let(:title) { 'httpd' }

    it {
      should contain_file('/etc/systemd/system/docker-httpd.service').with(
               {
                 'ensure'  => 'present',
                 'content' => <<-EOF\
[Unit]
Description=Docker Container Service for httpd
Requires=docker.service
After=docker.service

[Service]
Type=simple
Restart=always
RestartSec=5
EnvironmentFile=/etc/docker-httpd.env
ExecStartPre=-/usr/bin/docker stop httpd
ExecStartPre=-/usr/bin/docker rm httpd
ExecStart=/usr/bin/docker run --rm \\
    --name httpd \\
    $IMAGE_ARG $COMMAND
ExecStop=/usr/bin/docker stop httpd

[Install]
WantedBy=multi-user.target
EOF
               })
    }

    it {
      should contain_service('docker-httpd.service').with(
               {
                 'ensure'   => 'running',
                 'enable'   => 'true',
                 'provider' => 'systemd'
               })
    }

    it {
      should contain_file('/etc/docker-httpd.env').with(
        'ensure'  => 'present',
        'content' => <<-EOF
COMMAND=
IMAGE_ARG=httpd
EOF
      )
    }
  end

  context 'with all options configured' do

    let(:title) { 'webserver' }
    let(:params) {
      {
        :ensure       => 'stopped',
        :enable       => 'false',
        :image        => 'httpd',
        :command      => '-c "/bin/ls"',
        :depends      => ['dep1', 'dep2'],
        :volume       => ['/appdata', '/shared:/shared:rw'],
        :volumes_from => ['httpd-data'],
        :link         => ['l1:l1', 'l2:l2'],
        :publish      => ['80:80/tcp'],
        :entrypoint   => '/bin/bash',
        :env          => ['FOO=BAR', 'BAR=BAZ'],
        :env_file     => ['/etc/foo.list', '/etc/bar.list'],
      }
    }

    it { should contain_file('/etc/systemd/system/docker-webserver.service').with(
                  {
                    'ensure'  => 'present',
                    'content' => <<-EOF\
[Unit]
Description=Docker Container Service for webserver
Requires=docker.service docker-dep1.service docker-dep2.service
After=docker.service docker-dep1.service docker-dep2.service

[Service]
Type=simple
Restart=always
RestartSec=5
EnvironmentFile=/etc/docker-webserver.env
ExecStartPre=-/usr/bin/docker stop webserver
ExecStartPre=-/usr/bin/docker rm webserver
ExecStart=/usr/bin/docker run --rm \\
    --link l1:l1 --link l2:l2 \\
    --name webserver \\
    --publish 80:80/tcp \\
    --volume /appdata --volume /shared:/shared:rw \\
    --volumes-from httpd-data \\
    --entrypoint /bin/bash \\
    --env FOO=BAR --env BAR=BAZ \\
    --env-file /etc/foo.list --env-file /etc/bar.list \\
    $IMAGE_ARG $COMMAND
ExecStop=/usr/bin/docker stop webserver

[Install]
WantedBy=multi-user.target
EOF
                  })
    }

    it { should contain_service('docker-webserver.service').with(
                  {
                    'ensure'   => 'stopped',
                    'enable'   => 'false',
                    'provider' => 'systemd'
                  })
    }

    it {
      should contain_file('/etc/docker-webserver.env').with(
        'ensure'  => 'present',
        'content' => <<-EOF
COMMAND=-c "/bin/ls"
IMAGE_ARG=httpd
EOF
      )
    }
  end
end
