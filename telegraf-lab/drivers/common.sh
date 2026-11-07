# Shared driver setup: find the Telegraf binary and stand in
# the lab folder, where every config path is relative to.
# TELEGRAF_BIN may point at any telegraf binary; the lab was
# built with the official 1.40.3 tarball unpacked under the
# batch scratch folder, named below as the fallback.
TELEGRAF="${TELEGRAF_BIN:-$HOME/workspace/.batch-351-363/scratch-telegraf/telegraf-1.40.3/usr/bin/telegraf}"
[ -x "$TELEGRAF" ] || TELEGRAF="$(command -v telegraf || true)"
cd "$(dirname "$0")/.." || exit 1
mkdir -p outputs
