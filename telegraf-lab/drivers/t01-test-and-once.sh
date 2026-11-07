#!/bin/sh
. "$(dirname "$0")/common.sh"
echo "== config check on configs/system.conf =="
"$TELEGRAF" config check --config configs/system.conf 2>&1
echo "exit=$?"
echo
echo "== --test: one gather, printed, no output written =="
"$TELEGRAF" --config configs/system.conf --test 2>&1
echo "exit=$?"
echo
echo "== --once: one gather, written through the real output, then exit =="
rm -f outputs/system.lp
"$TELEGRAF" --config configs/system.conf --once 2>&1
echo "exit=$?"
echo "lines written to outputs/system.lp: $(wc -l < outputs/system.lp)"
echo "measurements seen:"
cut -d, -f1 outputs/system.lp | sort | uniq -c
