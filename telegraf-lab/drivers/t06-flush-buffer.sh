#!/bin/sh
. "$(dirname "$0")/common.sh"
echo "== configs/flush.conf: gather every 1s, flush every 3s, run 11 seconds =="
echo "== polling the output file once a second: watch it grow in batches =="
rm -f outputs/flush.lp
timeout 11 "$TELEGRAF" --config configs/flush.conf > outputs/flush-agent.log 2>&1 &
AGENT=$!
start=$(date +%s)
for i in $(seq 0 10); do
  lines=0
  [ -f outputs/flush.lp ] && lines=$(wc -l < outputs/flush.lp)
  echo "t=+$i s  lines in outputs/flush.lp: $lines"
  sleep 1
done
wait $AGENT
echo "agent stopped by timeout"
echo "final line count: $(wc -l < outputs/flush.lp)"
echo "first lines:"
head -3 outputs/flush.lp
