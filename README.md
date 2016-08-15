# docker_systemd

#### Table of Contents

 1. [Overview](#overview)
 2. [Module Description - What the module does and why it is useful](#module-description)
 3. [Setup - The basics of getting started with docker_systemd](#setup)
      * [What docker_systemd affects](#what-docker_systemd-affects)
      * [Setup requirements](#setup-requirements)
 4. [Usage - Configuration options and additional functionality](#usage)
 5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
 6. [Limitations - OS compatibility, etc.](#limitations)
 7. [Development - Guide for contributing to the module](#development)
 8. [Release Notes](#release-notes)

## Overview

This module creates systemd services to run Docker containers.

## Module Description

This module provides comprehensive systemd service configuration to manage the
running of Docker containers. An important feature it provides is it can
configure systemd dependencies so that Docker containers are started in the
correct order, which is needed for sharing volumes or establishing links
between containers. This is needed to support more sophisticated usage
patterns, such as data volume containers.

## Setup

### What docker_systemd affects

This module generates systemd unit files in `/etc/systemd/system`. These unit
files have a prefix of "docker-", followed by the name of the container.

When docker_systemd services are started, the resulting Docker containers will
be stored using Docker's storage driver.

If any Docker images are pulled as a result of running a Docker container,
those images will be stored using Docker's storage driver.

This module **does not** install Docker for you. Plenty of ways to install
Docker already exist, so this module does not add yet another way to do it.

This module **does not** build Docker images. If you need to build images, the
`puppetlabs/docker_platform` module does that just fine.

### Setup Requirements

This module requires Docker to be installed and running before any systemd
container services are run.

## Usage

### docker_systemd::container

`docker_systemd::container` configures a standalone Docker container to run
under systemd.

```.puppet
docker_systemd::container { "httpd":
  image   => "httpd",
  publish => ["80:80/tcp"],
  link    => ["db:db"],
  volume  => ["/var/www/html:/var/www/html:ro"]
}
```

In the above example, a systemd service is configured to run the httpd
container, and it publishes port 80 when it runs. The container starts
immediately and is configured to start on boot.  The container name is based on
the title and is named "httpd". The systemd service is also based on the title
and is named "docker-httpd.service".

The following options are available for `docker_systemd::container`:

  * `ensure`: Takes any `ensure` value accepted by the `Service` resource type
    (Default `running`).

  * `enable`: Takes any `enable` value accepted by the `Service` resource type
    (Default `true`).

  * `hostname`: The hostname associated with the container.

  * `image`: The name of the docker image to use.

  * `privileged`: If set to 'true' give extended privileges to this container.

  * `pull_image`: Always pull image before starting the container. (Default
    `false`)

  * `command`: Command and arguments to be run by the container.

  * `depends`: Dependencies on other systemd docker units which need to be
    started before this one. (List)

  * `volume`: Volumes to be used by this container. (List)

  * `volumes_from`: Containers which this container mounts volumes from. (List)

  * `link`: Containers which this container links to. (List)

  * `publish`: Ports which should be published by this container. (List)

  * `entrypoint`: Run this container with a different entrypoint.

  * `env`: Set environment variables in the container. (List)

  * `env_file`: Use environment file in the container. (List)

  * `systemd_env_file`: Path to a systemd environment file to use.

### docker_systemd::exec

`docker_systemd::exec` allows a `docker exec` command to be invoked within a
`docker_systemd::container`.  No additional containers are created for an
`exec` service, and it depends on the container which it runs against.

```.puppet
docker_systemd::exec { "httpd":
  command => "/bin/ls"
}
```

The above example configures `/bin/ls` to be run from within the container of
the "docker-httpd" service. The systemd service for this is named
"docker-httpd-exec.service" and it depends on "docker-httpd.service".

The following options are available for `docker_systemd::exec`:

  * command: Command and arguments to be run by the container.

  * container: Identifier of the container if different than the title.

### docker_systemd::data_volume_container

`docker_systemd::data_volume_container` configures a systemd unit for a data
volume container. This type of container is only run once at system startup,
and is run using an entrypoint of `/bin/true`. The main purpose of such a
container is to provide volume storage to other containers.

```.puppet
docker_systemd::data_volume_container { "httpd-data":
  image => "httpd"
}
```

The above example creates a data volume container named "httpd-data" from the
"httpd" image. The systemd service for this is named
"docker-httpd-data.service".

The following options are available for
`docker_systemd::data_volume_container`:

  * `image`: The name of the docker image to use.

  * `pull_image`: Always pull image before starting the container. (Default
    `false`)

  * `systemd_env_file`: Path to a systemd environment file to use.

For more information about the data volume container pattern, see the
official Docker documentation for
[Creating and mounting a data volume container](https://docs.docker.com/engine/userguide/dockervolumes/#creating-and-mounting-a-data-volume-container).

## Limitations

This module targets Red Hat Linux systems capable of running Docker:

* RHEL 7
* CentOS 7
* Fedora 20+

## Development

Issues and pull requests are welcome! Send those to:
<https://github.com/ajsmith/puppet-docker_systemd>

## Release Notes

### v0.4.0 (unreleased)

### v0.3.1

- Documentation updates.

### v0.3.0

- Automatically invoke 'systemctl daemon-reload' when unit files are updated.
- Add support for systemd environment files.
- Add option to always pull image before running containers.

### v0.2.3

- Add `--volume` option for containers.

### v0.2.2

- Add `--env` and `--env-file` configuration options for containers.

### v0.2.1

- Add Puppet version compatibility to metadata.

### v0.2.0

- Fixed a bug that prevented a container image from being configured.
- Added rspec tests for defined resource types.

### v0.1.3

- OS support info fixes.

### v0.1.2

- Metadata updates.

### v0.1.1

- Initial release.
