#!/usr/bin/env bash
#
# build/10-branding.sh — Sayanox OS Phase 1: ব্র্যান্ডিং
# রুটফাইলসিস্টেমে locale, ফন্ট, টাইমজোন, os-release, issue, hostname সেট করে।
#
# ব্যবহার:
#   sudo ./build/10-branding.sh <rootfs_dir> check   # প্রয়োজনীয় টুল আছে কি না যাচাই
#   sudo ./build/10-branding.sh <rootfs_dir> apply   # ব্র্যান্ডিং প্রয়োগ (চROOT-এর ভেতরে)
#
set -euo pipefail

ROOTFS="${1:-}"
MODE="${2:-apply}"
OVERLAY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../overlay" && pwd)"

fail() { echo "!! $*" >&2; exit 1; }
step() { echo "==> $*"; }

require_root() { [ "$(id -u)" -eq 0 ] || fail "root প্রয়োজন (sudo দিয়ে চালান)"; }

cmd_check() {
  echo "==> 10-branding চেক"
  local missing=0
  for c in locale-gen chroot dpkg sed ln rm cp; do
    command -v "$c" >/dev/null 2>&1 || { echo "   [miss] $c"; missing=1; }
  done
  [ -f "$OVERLAY_DIR/etc/os-release" ] || { echo "   [miss] overlay/etc/os-release"; missing=1; }
  [ -f "$OVERLAY_DIR/etc/issue" ]      || { echo "   [miss] overlay/etc/issue"; missing=1; }
  [ -f "$OVERLAY_DIR/etc/hostname" ]   || { echo "   [miss] overlay/etc/hostname"; missing=1; }
  if [ "$missing" -ne 0 ]; then fail "10-branding: কয়েকটি টুল/ফাইল অনুপস্থিত।"; fi
  echo "   [ok] সব টুল ও ওভারলੇ ফাইল উপস্থিত"
}

cmd_apply() {
  require_root
  [ -n "$ROOTFS" ] && [ -d "$ROOTFS" ] || fail "ব্যবহার: $0 <rootfs_dir> apply"

  step "ওভারলே ফাইল কপি ($ROOTFS/etc)"
  cp -a "$OVERLAY_DIR/etc/os-release" "$OVERLAY_DIR/etc/issue" "$OVERLAY_DIR/etc/hostname" "$ROOTFS/etc/"

  step "টাইমজোন Asia/Kolkata"
  ln -sf /usr/share/zoneinfo/Asia/Kolkata "$ROOTFS/etc/localtime"

  step "লোকেল সক্ষম: bn_IN.UTF-8, en_US.UTF-8"
  sed -i 's/^# *\(bn_IN\.UTF-8 UTF-8\)/\1/' "$ROOTFS/etc/locale.gen"
  sed -i 's/^# *\(en_US\.UTF-8 UTF-8\)/\1/' "$ROOTFS/etc/locale.gen"
  chroot "$ROOTFS" locale-gen

  step "ডিফল্ট লোকেল en_US.UTF-8, বাংলা সাপোর্ট"
  cat > "$ROOTFS/etc/default/locale" <<'EOF'
LANG=en_US.UTF-8
LANGUAGE=en_US:bn
LC_NUMERIC=bn_IN.UTF-8
LC_TIME=bn_IN.UTF-8
LC_MONETARY=bn_IN.UTF-8
EOF

  step "বাঙ்லা ফন্ট ইনস্টল (fonts-noto-bengali)"
  chroot "$ROOTFS" apt-get update -qq
  chroot "$ROOTFS" apt-get install -y -qq fonts-noto-bengali

  step "ব্র্যান্ডিং প্রয়োগ রady: $ROOTFS"
  echo "   পরের ধাপ: build/20-repo.sh (সayanoksen apt রেপো)"
}

case "$MODE" in
  check) cmd_check ;;
  apply) cmd_apply ;;
  *)     echo "ব্যবহার: $0 <rootfs_dir> {check|apply}" >&2; exit 1 ;;
esac
