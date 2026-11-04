#!/bin/sh
# Smoke test: build, start, wait for HTTP, check no crash. Optional env: PLATFORM=linux/amd64 EXTRA_CA=corp-ca.pem
set -eu
IMG=thbe/ntopng:test; C=t-ntopng; trap 'docker rm -f $C >/dev/null 2>&1' EXIT
docker build -q --pull --load ${PLATFORM:+--platform "$PLATFORM"} ${EXTRA_CA:+--secret id=extra_ca,src="$EXTRA_CA"} -t "$IMG" "$(dirname "$0")" >/dev/null
docker run -d ${PLATFORM:+--platform "$PLATFORM"} --name $C --cap-add=NET_RAW --cap-add=NET_ADMIN -p 13000:3000 "$IMG" >/dev/null
for i in $(seq 1 120); do
  curl -ksf -o /dev/null http://localhost:13000/ && { echo "PASS ntopng ($i s)"; exit 0; }
  [ "$(docker inspect -f '{{.State.Running}}' $C)" = true ] || break
  sleep 1
done
docker logs $C 2>&1 | tail -20; echo "FAIL ntopng"; exit 1
