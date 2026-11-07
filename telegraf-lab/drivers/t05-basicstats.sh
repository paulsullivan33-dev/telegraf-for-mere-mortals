#!/bin/sh
. "$(dirname "$0")/common.sh"
echo "== live run: configs/stats.conf, basicstats over 5s windows, 14 seconds =="
rm -f outputs/stats.lp
timeout 14 "$TELEGRAF" --config configs/stats.conf > outputs/stats-agent.log 2>&1 &
sleep 2
grep "Listening" outputs/stats-agent.log || true
for v in 10 20 30; do
  curl -s -o /dev/null -w "POST value=$v -> HTTP %{http_code}\n" -X POST \
    --data-binary "hall_temp,sensor=temp-north value=$v" \
    http://127.0.0.1:18083/telegraf
done
echo "waiting for the 5s aggregation window to close and flush..."
sleep 9
echo
echo "outputs/stats.lp (the three originals were dropped; only the summary remains):"
cat outputs/stats.lp 2>/dev/null || echo "(nothing written)"
wait
echo "agent stopped by timeout"
