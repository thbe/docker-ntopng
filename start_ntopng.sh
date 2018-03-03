#! /bin/sh
#
# Start docker image that provides a NTOPNG instance
#
# Author:       Thomas Bendler <project@bendler-net.de>
# Date:         Sat Mar  3 17:00:51 CET 2018
#
# Release:      v1.0
#
# ChangeLog:    v1.0 - Initial release
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
