FROM alpine
#
# BUILD:
#   wget https://raw.githubusercontent.com/thbe/docker-ntopng/master/Dockerfile
#   docker build --rm --no-cache -t thbe/ntopng .
#
# USAGE:
#   docker run --detach --restart always --cap-add=SYS_ADMIN -e "container=docker" \
#     --name ntopng --hostname ntopng.$(hostname -d) -p 3000:3000/tcp thbe/ntopng
#   docker logs ntopng
#   docker exec -ti ntopng /bin/sh
#

# Set metadata
LABEL maintainer="Thomas Bendler <project@bendler-net.de>"
LABEL version="1.0"
LABEL description="Creates an Alpine container serving a NTOPNG instance"

# Set environment
ENV LANG en_US.UTF-8
ENV TERM xterm

# Set workdir (fix missing pid directory)
WORKDIR /run/ntopng

# Install NTOPNG
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk add --no-cache curl perl redis ntopng ndpi

# Copy configuration files
COPY root /

# Prepare NTOPNG start
RUN chmod 755 /srv/run.sh

# Expose NTOPNG standard http port
EXPOSE 3000/tcp

# Start NTOPNG
CMD ["/srv/run.sh"]
