#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

TARGET="${1:-rtl8198c}"
MODE="${2:-firmware}"
JOBS="${JOBS:-2}"

case "$TARGET" in
  rtl8198c|rtl8198) ;;
  *) echo "Usage: $0 {rtl8198c|rtl8198} [firmware|sdk]"; exit 2 ;;
esac

echo "== Realtek RTL819X build =="
echo "Target : $TARGET"
echo "Kernel : Linux 4.4"
echo "Jobs   : $JOBS"
echo

command -v make >/dev/null || { echo "ERROR: make is not installed"; exit 1; }
command -v python3 >/dev/null || { echo "ERROR: python3 is not installed"; exit 1; }

if [ ! -f .config ]; then
  cat > .config <<EOF
CONFIG_TARGET_realtek=y
CONFIG_TARGET_realtek_${TARGET}=y
CONFIG_TARGET_BOARD="realtek"
CONFIG_CPU_TYPE="lexra"
CONFIG_TARGET_OPTIMIZATION="-Os -pipe -fno-caller-saves"
CONFIG_PACKAGE_wpad-mini=y
CONFIG_PACKAGE_swconfig=y
CONFIG_PACKAGE_kmod-gpio-button-hotplug=y
EOF
fi

echo "[1/5] Update feeds"
./scripts/feeds update -a
./scripts/feeds install -a

echo "[2/5] Configure target"
make FORCE=1 defconfig

echo "[3/5] Download sources"
make FORCE=1 download -j"$JOBS"

echo "[4/5] Build"
if [ "$MODE" = "sdk" ]; then
  make FORCE=1 tools/compile -j"$JOBS" V=s
  make FORCE=1 toolchain/compile -j"$JOBS" V=s
  make FORCE=1 target/sdk/compile -j1 V=s
else
  make FORCE=1 -j"$JOBS" V=s
fi

echo "[5/5] Output"
OUT="bin/targets/realtek/$TARGET"
if [ -d "$OUT" ]; then
  find "$OUT" -maxdepth 1 -type f -printf "%f %s bytes\\n" | sort
else
  echo "ERROR: output directory not found: $OUT"
  exit 1
fi

echo
echo "BUILD FINISHED: $TARGET"

# Ubuntu 20.04 / GitHub Actions build entrypoint.
