#!/bin/sh
. "$(dirname "$0")/common.sh"
echo "== configs/broken.conf names an input plugin that does not exist: cpuu =="
"$TELEGRAF" --config configs/broken.conf --test 2>&1
echo "exit=$?"
echo
echo "== a TOML syntax error (missing bracket), written to outputs/ for this test =="
printf '[agent\n  interval = "2s"\n' > outputs/broken-toml.conf
"$TELEGRAF" --config outputs/broken-toml.conf --test 2>&1
echo "exit=$?"
