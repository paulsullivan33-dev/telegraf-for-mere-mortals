#!/bin/sh
. "$(dirname "$0")/common.sh"
echo "== live run: configs/http.conf, listener on 127.0.0.1:18083, 8 seconds =="
rm -f outputs/http.lp
timeout 8 "$TELEGRAF" --config configs/http.conf > outputs/http-agent.log 2>&1 &
sleep 2
grep "Listening" outputs/http-agent.log || true
echo
echo "== POST one line-protocol point =="
curl -s -o /dev/null -w "HTTP status: %{http_code}\n" -X POST \
  --data-binary 'noticeboard_post,sensor=door-01,room=hall-a opens=3i,temperature_c=22.1 1794088200000000000' \
  http://127.0.0.1:18083/telegraf
echo
echo "== POST a malformed line =="
curl -s -o /dev/null -w "HTTP status: %{http_code}\n" -X POST \
  --data-binary 'this is not line protocol' \
  http://127.0.0.1:18083/telegraf
sleep 3
echo
echo "outputs/http.lp:"
cat outputs/http.lp 2>/dev/null || echo "(nothing written)"
wait
echo "agent stopped by timeout"
