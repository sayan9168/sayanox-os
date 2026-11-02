#!/usr/bin/env bash
#
# build/00-debootstrap.sh — Sayanox OS Phase 0
# Debian 13 "trixie" minbase রুটফাইলসিস্টেম বানাত mmdebstrap ব্যবহার করে।
#
# শর্তাবলি (বিল্ড হোস্টে):
#   - ডেবিয়ান হোস্ট (bookworm/trixie), root/sudo অ্যাক্সেস
#   - mmdebstrap, gnupg ইনস্টল করা
#   - deb.debian.org-এ নেটওয়ার্ক (সandbox-এ ব্লক থাকলে বিল্ড হয় नहीं)
#
# ব্যবহার:
#   sudo ./build/00-debootstrap.sh bootstrap   # রুটফাইলসিস্টেম তৈরি
#   sudo ./build/00-debootstrap.sh image       # (ঐচ্ছিক) কিউইএম বুটের জন্য raw ডিস্ক ইমেজ
#   ./build/00-debootstrap.sh check            # পরিবেশ যাচাই
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

ARCH="${SAX_ARCH:-amd64}"
SUITE="${SAX_SUITE:-trixie}"
MIRROR="${SAX_MIRROR:-https://deb.debian.org/debian}"
VARIANT="${SAX_VARIANT:-minbase}"
ROOTFS_DIR="${SAX_ROOTFS:-$REPO_ROOT/rootfs}"
IMAGE_FILE="${SAX_IMAGE:-$REPO_ROOT/sayanox-0.0.1.img}"
IMAGE_SIZE="${SAX_IMAGE_SIZE:-4G}"
OVERLAY_DIR="$REPO_ROOT/overlay"

EXTRA_PKGS=(
  systemd-sysv
  dbus
  ca-certificates
  cron
  locales
)

step() { echo "==> $*"; }
err()  { echo "!! $*" >&2; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || { err "প্রয়োজনীয় কমান্ড পাওয়া নিয়ে না: $1"; return 1; }
}

require_root() {
  [ "$(id -u)" -eq 0 ] || { err "এই কাজের জন্য root প্রয়োজন (sudo দিয়ে চালান)"; return 1; }
}

cmd_check() {
  echo "==> Sayanox OS Phase 0 পরিবেশ যাচাই"
  local missing=0
  for c in mmdebstrap gpg qemu-system-x86_64 grub-install mksquashfs xorriso; do
    if command -v "$c" >/dev/null 2>&1; then
      echo "   [ok] $c"
    else
      echo "   [miss] $c"
      missing=1
    fi
  done
  echo "  arch: $(dpkg --print-architecture 2>/dev/null || uname -m)"
  echo "   suite: $SUITE  mirror: $MIRROR  rootfs: $ROOTFS_DIR"
  if [ "$missing" -ne 0 ]; then
    err "কয়েকটি টুল অনুপস্থিত — Package installer দিয়ে ইনস্টল করুন (যা স্যান্ডবক্সে নেটওয়ার্ক ব্লক থাকলে সম্ভব নাও হতে পারে)"
    return 1
  fi
  echo "==> সব টুল উপস্থিত"
}

cmd_bootstrap() {
  require_cmd mmdebstrap
  require_root

  step "প্রস্তুতি: mmdebstrap দিয়ে $SUITE ($ARCH) → $ROOTFS_DIR"
  mkdir -p "$ROOTFS_DIR"

  mmdebstrap \
    --arch="$ARCH" \
    --variant="$VARIANT" \
    --mode=chroot \
    "$SUITE" "$ROOTFS_DIR" "$MIRROR" \
    "${EXTRA_PKGS[@]}"

  step "ওভারলے ফাইলগুলো কপি করা হচ্ছে ($OVERLAY_DIR → $ROOTFS_DIR)"
  cp -a "$OVERLAY_DIR/." "$ROOTFS_DIR/"

  step "রুটফাইলসিস্টেম রady: $ROOTFS_DIR"
  echo "   পরের ধাপ: sudo chroot $ROOTFS_DIR /bin/bash থেকে ইন্টারঅ্যাক্টিভ টেস্ট,"
  echo "   তারপর build/10-branding.sh (সettelment, Plymouth, ফন্ট, ডিসপ্লে ম্যানেজার)"
}

cmd_image() {
  require_cmd mmdebstrap || true
  require_cmd qemu-img || { err "qemu-img ছাড়া ইমেজ বানানো যায় না"; return 1; }
  require_cmd grub-install || { err "grub-install ছাড়া বুটেবল ইমেজ যায় না"; return 1; }
  require_root

  if [ ! -d "$ROOTFS_DIR" ] || [ -z "$(ls -A "$ROOTFS_DIR")" ]; then
    err "রুটফাইলসিস্টেম খালি/নেই — আগে 'bootstrap' চালান"
    return 1
  fi

  step "raw ডিস্ক ইমেজ তৈরি: $IMAGE_FILE ($IMAGE_SIZE)"
  qemu-img create -f raw "$IMAGE_FILE" "$IMAGE_SIZE"

  step "পার্টিশন + ext4"
  sfdisk "$IMAGE_FILE" <<'EOF'
label: dos
type=83, bootable
EOF
  LOOP="$(losetup -fP --show "$IMAGE_FILE")"
  mkfs.ext4 -q "${LOOP}p1"
  MNT="$(mktemp -d)"
  mount "${LOOP}p1" "$MNT"
  cp -a "$ROOTFS_DIR/." "$MNT/"

  step "GRUB (i386-pc) ইন্সটল করা"
  grub-install --target=i386-pc --boot-directory="$MNT/boot" --modules="part_msdos ext2" "$LOOP"

  cat > "$MNT/boot/grub/grub.cfg" <<'EOF'
set default=0
set timeout=5

menuentry "Sayanox OS" {
  linux   /boot/vmlinuz root=/dev/sda1 ro quiet
  initrd  /boot/initrd.img
}
EOF

  umount "$MNT"
  rmdir "$MNT"
  losetup -d "$LOOP"
  step "ইমেজ রady: $IMAGE_FILE  (কিউইএম: qemu-system-x86_64 -hda $IMAGE_FILE -m 2048)"
}

usage() {
  cat <<EOF
ব্যবহার: $0 {bootstrap|image|check}
  bootstrap - trixie minbase রুটফাইলসিস্টেম তৈরি (mmdebstrap)
  image     - কিউইএম বুটেবল raw ইমেজ তৈরি (ঐচ্ছিক)
  check     - বিল্ড পরিবেশ যাচাই
EOF
}

main() {
  case "${1:-}" in
    bootstrap) cmd_bootstrap ;;
    image)     cmd_image ;;
    check)     cmd_check ;;
    *)         usage; exit 1 ;;
  esac
}

main "$@"
