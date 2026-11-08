#!/usr/bin/env bash
#
# build/10-branding.sh — Sayanox OS Phase 1
# রুটফাইলসিস্টেমে ব্যান্ডিং প্রয়োগ: লোকেল, পlymouth, GRUB থিম, ডিসপ্লে ম্যানেজার, বাংলা ফন্ট।
#
# শর্তাবলি (বিল্ড হোস্টে): root/sudo অ্যাক্সেস, ডেবিয়ান bookworm/trixie, নেটওয়ার্ক
#
# ব্যবহার:
#   sudo ./build/10-branding.sh apply   # রুটফাইলসিস্টেমে Phase 1 ব্যান্ডিং প্রয়োগ
#   sudo ./build/10-branding.sh check   # প্রয়োজনীয় টুল যাচাই
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ROOTFS_DIR="${SAX_ROOTFS:-$REPO_ROOT/rootfs}"
OVERLAY_DIR="$REPO_ROOT/overlay"
BRANDING_DIR="$REPO_ROOT/branding"

PHASE1_PKGS=(
  plymouth
  plymouth-themes
  fonts-noto-bengali
  sddm
  grub-pc
  locales
  console-setup
  keyboard-configuration
)

step() { echo "==> $*"; }
err()  { echo "!! $*" >&2; }

require_root() {
  [ "$(id -u)" -eq 0 ] || { err "এই কাজের জন্য root প্রয়োজন (sudo দিয়ে চালান)"; return 1; }
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || { err "প্রয়োজনীয় কমান্ড পাওয়া নিয়ে না: $1"; return 1; }
}

cmd_check() {
  echo "==> Sayanox OS Phase 1 পরিবেশ যাচাই"
  local missing=0
  for c in chroot locale-gen update-locale mksquashfs grub-mkrescue xorriso; do
    if command -v "$c" >/dev/null 2>&1; then echo "   [ok] $c"; else echo "   [miss] $c"; missing=1; fi
  done
  echo "   rootfs: $ROOTFS_DIR"
  if [ "$missing" -ne 0 ]; then return 1; fi
  echo "==> সব টুল উপস্থিত"
}

cmd_apply() {
  require_root

  if [ ! -d "$ROOTFS_DIR" ] || [ -z "$(ls -A "$ROOTFS_DIR")" ]; then
    err "রুটফাইলসিস্টেম খালি/নেই — আগে build/00-debootstrap.sh bootstrap চালান"
    return 1
  fi

  step "১. ওভারলে ফাইলগুলো রুটফাইলসিস্টেমে কপি ($OVERLAY_DIR → $ROOTFS_DIR)"
  cp -a "$OVERLAY_DIR/." "$ROOTFS_DIR/"

  step "২. Phase 1 প্যাকেজ ইনস্টলেশন (চ roots-এর ভেতরে apt)"
  # নোট: চ roots-এর ভেতরে নেটওয়ার্ক প্রয়োজন; স্যান্ডবক্সে নেটওয়ার্ক ব্লক থাকলে এই ধাপ বিল্ড হোস্টে চালু করুন
  chroot "$ROOTFS_DIR" apt-get update
  chroot "$ROOTFS_DIR" apt-get install -y --no-install-recommends "${PHASE1_PKGS[@]}"

  step "৩. লোকেল সেটআপ (bn_IN.UTF-8 + en_US.UTF-8)"
  chroot "$ROOTFS_DIR" locale-gen en_US.UTF-8 bn_IN.UTF-8
  chroot "$ROOTFS_DIR" update-locale LANG=en_US.UTF-8 LC_NUMERIC=bn_IN.UTF-8 LC_TIME=bn_IN.UTF-8 LC_MONETARY=bn_IN.UTF-8 LC_PAPER=bn_IN.UTF-8 LC_MEASUREMENT=bn_IN.UTF-8

  step "৪. GRUB থিম + 월পেপার (boot/grub/themes/sayanox)"
  mkdir -p "$ROOTFS_DIR/boot/grub/themes/sayanox"
  cp -a "$BRANDING_DIR/sayanox-wallpaper.png" "$ROOTFS_DIR/boot/grub/themes/sayanox/wallpaper.png"
  cp -a "$OVERLAY_DIR/boot/grub/themes/sayanox/theme.txt" "$ROOTFS_DIR/boot/grub/themes/sayanox/theme.txt"
  if command -v grub-mkconfig >/dev/null 2>&1; then
    chroot "$ROOTFS_DIR" grub-mkconfig -o /boot/grub/grub.cfg || true
  fi

  step "৫. পlymouth থিম ডিফল্ট হিসেবে সেট (sayanox)"
  if command -v plymouth-set-default-theme >/dev/null 2>&1; then
    chroot "$ROOTFS_DIR" plymouth-set-default-theme sayanox || true
  fi
  if command -v update-initramfs >/dev/null 2>&1; then
    chroot "$ROOTFS_DIR" update-initramfs -u || true
  fi

  step "৬. ডিসপ্লে ম্যানেজার (sddm) — থিম ওভারলে কাজে লাগানো হয়েছে (overlay/etc/sddm.conf.d/sayanox.conf)"

  step "ব্যান্ডিং সম্পন্ন: $ROOTFS_DIR"
  echo "   পরের ধাপ: sudo ./build/20-iso.sh iso  (sqaushfs + GRUB → sayanox-0.0.1.iso)"
}

usage() {
  cat <<EOF
ব্যবহার: $0 {apply|check}
  apply  - রুটফাইলসিস্টেমে Phase 1 ব্যান্ডিং প্রয়োগ (চ roots-ভিত্তিক)
  check  - বিল্ড পরিবেশ যাচাই
EOF
}

main() {
  case "${1:-}" in
    apply) cmd_apply ;;
    check) cmd_check ;;
    *)     usage; exit 1 ;;
  esac
}

main "$@"
