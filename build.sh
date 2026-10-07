#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"
TARGET="${1:-rtl8198c}"
MODE="${2:-firmware}"
case "$TARGET" in
  rtl8198c|rtl8198) SUBTARGET="$TARGET" ;;
  *) echo "Usage: $0 {rtl8198c|rtl8198} [firmware|sdk]"; exit 2 ;;
esac
./scripts/feeds update -a
./scripts/feeds install -a
cat > .config <<EOF
CONFIG_TARGET_realtek=y
CONFIG_TARGET_realtek_SUBTARGET=y
CONFIG_TARGET_BOARD="realtek"
CONFIG_TARGET_ARCH_PACKAGES="realtek_lx"
CONFIG_CPU_TYPE="lexra"
CONFIG_TARGET_OPTIMIZATION="-Os -pipe -fno-caller-saves"
CONFIG_PACKAGE_wpad-mini=y
CONFIG_PACKAGE_swconfig=y
CONFIG_PACKAGE_kmod-gpio-button-hotplug=y
EOF
sed -i "s/CONFIG_TARGET_realtek_SUBTARGET=y/CONFIG_TARGET_realtek_${SUBTARGET}=y/" .config
for p in kmod-rtl8192er kmod-rtl8812er kmod-rtl8192ce kmod-rtl8192de kmod-rtl8192se kmod-rtl8192cd; do
  if grep -Rqs "^define KernelPackage/$p\\b" package target 2>/dev/null; then
    echo "CONFIG_PACKAGE_$p=y" >> .config
  fi
done
make FORCE=1 defconfig
make FORCE=1 download -j"${JOBS:-4}"
if [ "$MODE" = "sdk" ]; then
  make FORCE=1 tools/compile -j"${JOBS:-2}" V=s
  make FORCE=1 toolchain/compile -j"${JOBS:-2}" V=s
  make FORCE=1 target/sdk/compile -j1 V=s
else
  make FORCE=1 -j"${JOBS:-2}" V=s
fi
find "bin/targets/realtek/$SUBTARGET" -maxdepth 1 -type f -printf '%f %s bytes\\n' 2>/dev/null || true
