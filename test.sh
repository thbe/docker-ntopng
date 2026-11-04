#!/bin/sh
# Smoke test: build, start, wait for HTTP http://localhost:13000/, check no restart/crash. Usage: ./test.sh
set -eu
IMG=thbe/ntopngest; C=t-ntopng; trap 'docker rm -f $C >/dev/null 2>&1' EXIT
docker build -q --pull --load -t "$IMG" "$(dirname "$0")" >/dev/null
docker run -d --name $C --cap-add=NET_RAW --cap-add=NET_ADMIN -p 13000:3000 "$IMG" >/dev/null
for i in $(seq 1 60); do
  curl -ksf -o /dev/null http://localhost:13000/ && { echo "PASS ntopng ($i s)"; exit 0; }
  [ "$(docker inspect -f '{{.State.Running}}' $C)" = true ] || break
  sleep 1
done
docker logs $C 2>&1 | tail -20; echo "FAIL ntopng"; exit 1
