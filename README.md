# ntopng on Docker

[![Build Status](https://img.shields.io/docker/automated/thbe/ntopng.svg)](https://hub.docker.com/r/thbe/ntopng/builds/) [![GitHub Stars](https://img.shields.io/github/stars/thbe/docker-ntopng.svg)](https://github.com/thbe/docker-ntopng/stargazers) [![Docker Stars](https://img.shields.io/docker/stars/thbe/ntopng.svg)](https://hub.docker.com/r/thbe/ntopng) [![Docker Pulls](https://img.shields.io/docker/pulls/thbe/ntopng.svg)](https://hub.docker.com/r/thbe/ntopng)

This is a Docker image to run a NTOPNG instance.

This Docker image is based on the offical [Alpine](https://hub.docker.com/r/_/alpine/) image.

#### Table of Contents

- [Install Docker](https://github.com/thbe/docker-ntopng#install-docker)
- [Download](https://github.com/thbe/docker-ntopng#download)
- [How to use this image](https://github.com/thbe/docker-ntopng#how-to-use-this-image)
- [Next steps](https://github.com/thbe/docker-ntopng#next-steps)
- [Important notes](https://github.com/thbe/docker-ntopng#important-notes)
- [Update Docker image](https://github.com/thbe/docker-ntopng#update-docker-image)
- [Advanced usage](https://github.com/thbe/docker-ntopng#advanced-usage)
- [Technical details](https://github.com/thbe/docker-ntopng#technical-details)
- [Development](https://github.com/thbe/docker-ntopng#development)

## Install Docker

To use this image you have to [install Docker](https://docs.docker.com/engine/installation/) first.

## Download

You can get the trusted build from the [Docker Hub registry](https://hub.docker.com/r/thbe/ntopng/):

```
docker pull thbe/ntopng
```

Alternatively, you may build the Docker image from the
[source code](https://github.com/thbe/docker-ntopng#build-from-source-code) on GitHub.

## How to use this image

### Environment variables

You can use two environment variables that will be recognized by the start script.

#### `ARG0`

The first argument indicates that the NTOPNG should monitor the FRITZ box.

#### `ARG1`

The second argument indicates what interface at the FRITZ box should be monitored.

#### `ARG2`

The third argument is the password for the FRITZ box.

#### `NTOPNG_DEBUG`

If this environment variable is set, the scripts inside the container will run in debug mode.

### Start the NTOPNG instance

The instance can be started by the [start script](https://raw.githubusercontent.com/thbe/docker-ntopng/master/start_ntopng.sh)
from GitHub:

```
wget https://raw.githubusercontent.com/thbe/docker-ntopng/master/start_ntopng.sh
chmod 755 start_ntopng.sh
./start_ntopng.sh
```

If you want to monitor your FRITZ box you have to add the following paramter to the start script:

```
wget https://raw.githubusercontent.com/thbe/docker-ntopng/master/start_ntopng.sh
chmod 755 start_ntopng.sh
./start_ntopng.sh "true" "lan" "secret"
```

### Check server status

You can use the standard Docker commands to examine the status of the NTOPNG instance:

```
docker logs --tail 1000 --follow --timestamps ntopng
```

## Next steps

The next release of this Docker image should have a persistent NTOPNG configuration.

## Important notes

The username for the web server is `root`/`password` unless you don't change the password with the environment
variable as described in the [Environment variables](https://github.com/thbe/docker-ntopng#how-to-use-this-image)
section.

## Update Docker image

Simply download the trusted build from the [Docker Hub registry](https://hub.docker.com/r/thbe/ntopng/):

```
docker pull thbe/ntopng
```

## Advanced usage

### Build from source code

You can build the image also from source. To do this you have to clone the
[docker-ntopng](https://github.com/thbe/docker-ntopng) repository from GitHub:

```
git clone https://github.com/thbe/docker-ntopng.git
cd docker-ntopng
docker build --rm --no-cache -t thbe/ntopng .
```

### Bash shell inside container

If you need a shell inside the container you can run the following command:

```
docker exec -ti ntopng /bin/sh
```

## Technical details

- Alpine base image
- ntopng binary from official Alpine package repository

## Development

If you like to add functions or improve this Docker image, feel free to fork the repository and send me a merge request with the modification.
