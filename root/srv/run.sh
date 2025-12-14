#!/bin/bash
#
# Start NTOPNG instance
#
# Author:       Thomas Bendler <code@thbe.org>
# Date:         Mon Mar 23 22:29:36 CET 2020
#
# Release:      v2.0
#
# ChangeLog:    v1.0 - Initial release
#               v1.5 - Switch to Ubuntu
#               v2.0 - Optimizations and fixes
#

### Enable debug if debug flag is true ###
if [ -n "${NTOPNG_ENV_DEBUG}" ]; then
  set -ex
fi

### Error handling ###
error_handling() {
  if [ "${RETURN}" -eq 0 ]; then
    echo "${SCRIPT} successfull!"
  else
    echo "${SCRIPT} aborted, reason: ${REASON}"
  fi
  exit "${RETURN}"
}
trap "error_handling" EXIT HUP INT QUIT TERM
RETURN=0
REASON="Finished!"

### Default values ###
export PATH=/usr/sbin:/usr/bin:/sbin:/bin
export LC_ALL=C.UTF-8
export LANG=C.UTF-8
SCRIPT=$(basename "${0}")

### Check if FritzBox should be monitored ###
if [ -n "${NTOPNG_ENV_FRITZBOX_CAPTURE}" ]; then

  ### Get FritzBox capture interface (wan/lan) ###
  if [ -n "${NTOPNG_ENV_FRITZBOX_IFACE}" ]; then
    if [ "${NTOPNG_ENV_FRITZBOX_IFACE}" = "wan" ]; then
      # FRITZBOX_IFACE="3-17"
      FRITZBOX_IFACE="2-0"
    else
      FRITZBOX_IFACE="1-lan"
    fi
  fi

  ### Get FritzBox password ###
  if [ -n "${NTOPNG_ENV_FRITZBOX_PASSWORD}" ]; then
    FRITZBOX_PASSWORD=${NTOPNG_ENV_FRITZBOX_PASSWORD}
  fi

  ### Create FritzBox SID file ###
  FRITZBOX_SIDFILE="/tmp/fritz.sid"
  if [ ! -f "${FRITZBOX_SIDFILE}" ]; then
    touch "${FRITZBOX_SIDFILE}"
  fi
  FRITZBOX_SID=$(cat "${FRITZBOX_SIDFILE}")

  ### Request FritzBox challenge token ###
  FRITZBOX_CHALLENGE=$(curl -k -s http://fritz.box/login_sid.lua | grep -o "<Challenge>[a-z0-9]\{8\}" | cut -d'>' -f 2)

  ### Create FritzBox password hash ###
  FRITZBOX_HASH=$(perl -MPOSIX -e '
    use Digest::MD5 "md5_hex";
    my $ch_Pw = "$ARGV[0]-$ARGV[1]";
    $ch_Pw =~ s/(.)/$1 . chr(0)/eg;
    my $md5 = lc(md5_hex($ch_Pw));
    print $md5;
  ' -- "${FRITZBOX_CHALLENGE}" "${FRITZBOX_PASSWORD}")
  curl -k -s "http://fritz.box/login_sid.lua" -d "response=${FRITZBOX_CHALLENGE}-${FRITZBOX_HASH}" -d 'username=dslf-config' | grep -o "<SID>[a-z0-9]\{16\}" | cut -d'>' -f 2 > "${FRITZBOX_SIDFILE}"
  FRITZBOX_SID=$(cat "${FRITZBOX_SIDFILE}")

  ### Check if FritzBox authentification was successful ###
  if [[ "${FRITZBOX_SID}" =~ ^0+$ ]]; then
    echo "Login failed! Fallback to normal startup"
    unset NTOPNG_ENV_FRITZBOX_CAPTURE
  fi
fi

### Display NTOPNG connection parameter ###
cat <<EOF

===========================================================

The dockerized NTOPNG instance is now ready for use! The web
interface is available here:

URL:                  http://${NTOPNG_ENV_HOST}/
Username:             admin
Password:             admin

FRITZ box monitoring: ${NTOPNG_ENV_FRITZBOX_CAPTURE}
FRITZ box interface:  ${FRITZBOX_IFACE}

===========================================================

EOF

### Start the REDIS instance ###
redis-server /etc/redis/redis.conf --daemonize yes

### Wait for Redis to be ready ###
sleep 2

### Start the NTOPNG instance ###
NTOPNG_COMMAND="ntopng"
FRITZBOX_URL="http://fritz.box/cgi-bin/capture_notimeout?ifaceorminor=${FRITZBOX_IFACE}&snaplen=&capture=Start&sid=${FRITZBOX_SID}"
if [ -n "${NTOPNG_ENV_FRITZBOX_CAPTURE}" ]; then
  exec wget --no-check-certificate -qO- "${FRITZBOX_URL}" | ${NTOPNG_COMMAND} -i -
else
  exec ${NTOPNG_COMMAND}
fi
