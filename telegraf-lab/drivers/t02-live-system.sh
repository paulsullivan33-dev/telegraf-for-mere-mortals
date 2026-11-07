#!/bin/sh
. "$(dirname "$0")/common.sh"
echo "== live run: configs/system.conf for 9 seconds (timeout stops it) =="
rm -f outputs/system.lp
timeout 9 "$TELEGRAF" --config configs/system.conf 2>&1
echo "timeout exit=$? (124 means timeout stopped a still-running agent, as designed)"
echo
echo "lines in outputs/system.lp: $(wc -l < outputs/system.lp)"
echo "measurements seen:"
cut -d, -f1 outputs/system.lp | sort | uniq -c
echo
echo "== the file output, verbatim =="
cat outputs/system.lp
