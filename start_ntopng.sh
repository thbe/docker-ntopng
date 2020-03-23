#! /bin/sh
#
# Start docker image that provides a NTOPNG instance
#
# Author:       Thomas Bendler <code@thbe.org>
# Date:         Mon Mar 23 22:29:36 CET 2020
#
# Release:      v1.5
#
# ChangeLog:    v1.0 - Initial release
#               v1.5 - Switch to Ubuntu
#

### Run docker instance ###
docker run --detach --restart always \
  --cap-add=SYS_ADMIN -e "container=docker" \
  -e NTOPNG_ENV_HOST="$(hostname -f)" \
  -e NTOPNG_ENV_FRITZBOX_CAPTURE="${1}" \
  -e NTOPNG_ENV_FRITZBOX_IFACE="${2}" \
  -e NTOPNG_ENV_FRITZBOX_PASSWORD="${3}" \
  -e NTOPNG_ENV_DEBUG="${NTOPNG_DEBUG}" \
  --name ntopng --hostname ntopng.$(hostname -f | sed -e 's/^[^.]*\.//') \
  -p 3000:3000/tcp \
  thbe/ntopng
