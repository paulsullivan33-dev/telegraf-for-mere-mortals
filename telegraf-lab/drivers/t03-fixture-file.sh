#!/bin/sh
. "$(dirname "$0")/common.sh"
echo "== the fixture: fixtures/readings.json =="
cat fixtures/readings.json
echo
echo "== --test on configs/fixture.conf (JSON parsed, tags chosen, field renamed) =="
"$TELEGRAF" --config configs/fixture.conf --test 2>&1
echo "exit=$?"
echo
echo "== --once through the real file output =="
rm -f outputs/fixture.lp
"$TELEGRAF" --config configs/fixture.conf --once 2>&1 | tail -3
echo "outputs/fixture.lp:"
cat outputs/fixture.lp
