# syntax=docker/dockerfile:1
FROM debian:trixie
#
# BUILD:
#   docker build --rm --no-cache -t thbe/ntopng .
#   (behind TLS inspection add: --secret id=extra_ca,src=corp-ca.pem; removed again after install)
#
# USAGE:
#   docker run --detach --restart always --cap-add=NET_RAW --cap-add=NET_ADMIN \
#     --name ntopng --hostname ntopng.$(hostname -d) -p 3000:3000/tcp thbe/ntopng
#   docker logs ntopng
#   docker exec -ti ntopng /bin/bash
#

# Set metadata
LABEL maintainer="Thomas Bendler <code@thbe.org>"
LABEL version="3.0"
LABEL description="Creates a Debian container serving an NTOPNG instance"

# Set environment
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TERM=linux \
    DEBIAN_FRONTEND=noninteractive

# Install nDPI and NTOPNG in a single optimized layer
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=secret,id=extra_ca,required=false \
    if [ -s /run/secrets/extra_ca ]; then mkdir -p /usr/local/share/ca-certificates && cp /run/secrets/extra_ca /usr/local/share/ca-certificates/extra.crt; fi && \
    apt-get update && \
    apt-get -y --no-install-recommends upgrade && \
    apt-get -y --no-install-recommends install \
        curl \
        wget \
        ca-certificates \
        perl \
        libdigest-perl-md5-perl \
        redis-server \
        gnupg && \
    update-ca-certificates && \
    wget -q https://packages.ntop.org/apt-stable/trixie/all/apt-ntop-stable.deb -O /tmp/apt-ntop.deb && \
    apt-get -y install /tmp/apt-ntop.deb && \
    apt-get update && \
    apt-get -y --no-install-recommends install ntopng ntopng-data && \
    rm -f /usr/local/share/ca-certificates/extra.crt && update-ca-certificates --fresh && \
    find /var/log -type f -delete && rm -rf /tmp/* /var/tmp/*

# Copy configuration files
COPY --chmod=755 root /

# Expose NTOPNG standard http port
EXPOSE 3000/tcp

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1

# Start NTOPNG
CMD ["/srv/run.sh"]
