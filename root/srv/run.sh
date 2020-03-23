#! /bin/sh
#
# Start NTOPNG instance
#
# Author:       Thomas Bendler <code@thbe.org>
# Date:         Mon Mar 23 22:29:36 CET 2020
#
# Release:      v1.5
#
# Prerequisite: This release needs a shell which could handle functions.
#               If shell is not able to handle functions, remove the
#               error section.
#
# ChangeLog:    v1.0 - Initial release
#               v1.5 - Switch to Ubuntu
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
export LC_ALL=C
export LANG=C
SCRIPT=$(basename ${0})

### Check if FRITZ box should be monitored ###
if [ -n "${NTOPNG_ENV_FRITZBOX_CAPTURE}" ]; then
  FRITZBOX_CAPTURE="true"

  ### Get FRITZ box password ###
  if [ -n "${NTOPNG_ENV_FRITZBOX_IFACE}" ]; then
    if [ "${NTOPNG_ENV_FRITZBOX_IFACE}" == "wan" ]; then
      FRITZBOX_IFACE="3-17"
    else
      FRITZBOX_IFACE="1-lan"
    fi
  fi

  ### Get FRITZ box password ###
  if [ -n "${NTOPNG_ENV_FRITZBOX_PASSWORD}" ]; then
    FRITZBOX_PASSWORD=${NTOPNG_ENV_FRITZBOX_PASSWORD}
  fi

  ### The is the address of the FRITZ box ###
  FRITZBOX_IP=$(nslookup fritz.box 2> /dev/null | grep dress | cut -d' ' -f3)

  FRITZBOX_SIDFILE="/tmp/fritz.sid"
  FRITZBOX_CHALLENGE=$(curl -s http://${FRITZBOX_IP}/login_sid.lua |  grep -o "<Challenge>[a-z0-9]\{8\}" | cut -d'>' -f2)
  FRITZBOX_HASH=$(perl -MPOSIX -e '
      use Digest::MD5 "md5_hex";
      my $ch_Pw = "$ARGV[0]-$ARGV[1]";
      $ch_Pw =~ s/(.)/$1 . chr(0)/eg;
      my $md5 = lc(md5_hex($ch_Pw));
      print $md5;
    ' -- "${FRITZBOX_CHALLENGE}" "${FRITZBOX_PASSWORD}")
  FRITZBOX_SID=$(curl -s "http://${FRITZBOX_IP}/login_sid.lua" -d "response=${FRITZBOX_CHALLENGE}-${FRITZBOX_HASH}" \
                      -d 'username=' | grep -o "<SID>[a-z0-9]\{16\}" | cut -d'>' -f2)
else
  FRITZBOX_CAPTURE="false"
fi

cat <<EOF

===========================================================

The dockerized NTOPNG instance is now ready for use! The web
interface is available here:

URL:                  http://${NTOPNG_ENV_HOST}/
Username:             admin
Password:             admin

FRITZ box monitoring: ${FRITZBOX_CAPTURE}
FRITZ box interface:  ${FRITZBOX_IFACE}

===========================================================

EOF

### Start REDIS instance ###
/usr/bin/redis-server /etc/redis/redis.conf

### Start NTOPNG instance ###
NTOPNG_COMMAND="/usr/sbin/ntopng --dns-mode 1"
FRITZBOX_URL="http://${FRITZBOX_IP}/cgi-bin/capture_notimeout?ifaceorminor=${FRITZBOX_IFACE}&snaplen=&capture=Start&sid=${FRITZBOX_SID}"
if [ ${FRITZBOX_CAPTURE} == "true" ]; then
  wget -qO- ${FRITZBOX_URL} | ${NTOPNG_COMMAND} -i -
else
  ${NTOPNG_COMMAND}
fi
