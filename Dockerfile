FROM ubuntu:focal
#
# BUILD:
#   wget https://raw.githubusercontent.com/thbe/docker-ntopng/master/Dockerfile
#   docker build --rm --no-cache -t thbe/ntopng .
#
# USAGE:
#   docker run --detach --restart always --cap-add=SYS_ADMIN -e "container=docker" \
#     --name ntopng --hostname ntopng.$(hostname -d) -p 3000:3000/tcp thbe/ntopng
#   docker logs ntopng
#   docker exec -ti ntopng /bin/bash
#

# Set metadata
LABEL maintainer="Thomas Bendler <code@thbe.org>"
LABEL version="1.5"
LABEL description="Creates an Ubuntu container serving an NTOPNG instance"

# Set environment
ENV LANG C
ENV TERM linux
ENV DEBIAN_FRONTEND noninteractive

# Install nDPI and NTOPNG
RUN apt-get clean all && apt-get update && apt-get -y dist-upgrade && \
  apt-get -y install net-tools curl wget perl libdigest-perl-md5-perl ntopng && \
    apt-get clean all

# Copy configuration files
COPY root /

# Prepare NTOPNG start
RUN chmod 755 /srv/run.sh

# Expose NTOPNG standard http port
EXPOSE 3000/tcp

# Start NTOPNG
CMD ["/srv/run.sh"]
