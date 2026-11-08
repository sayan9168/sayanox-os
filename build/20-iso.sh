#!/usr/bin/env bash
#
# build/20-iso.sh — Sayanox OS Phase 1
# squashfs + GRUB → sayanox-0.0.1.iso (লাইভ আইএসও, বুটেবল)
#
# শর্তাবলি (বিল্ড হোস্টে): root/sudo, mksquashfs, grub-mkrescue, xorriso, grub-pc
#   ইউএফআই বুটের জন্য grub-efi-amd64 বাইনারি প্রয়োজন (পর্ব ৩-এ UEFI + সিকিউর বুট পরিকল্পিত)
#
# ব্যবহার:
#   sudo ./build/20-iso.sh iso      # sayanox-0.0.1.iso তৈরি
#   sudo ./build/20-iso.sh check    # টুল যাচাই
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ROOTFS_DIR="${SAX_ROOTFS:-$REPO_ROOT/rootfs}"
ISO_DIR="$REPO_ROOT/image"
ISO_FILE="$REPO_ROOT/sayanox-0.0.1.iso"

step() { echo "==> $*"; }
err()  { echo "!! $*" >&2; }

require_root() {
  [ "$(id -u)" -eq 0 ] || { err "এই কাজের জন্য root প্রয়োজন (sudo দিয়ে চালান)"; return 1; }
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || { err "প্রয়োজনীয় কমান্ড পাওয়া নিয়ে না: $1"; return 1; }
}

cmd_check() {
  echo "==> Sayanox OS Phase 1 (ISO) পরিবেশ যাচাই"
  local missing=0
  for c in mksquashfs grub-mkrescue xorriso; do
    if command -v "$c" >/dev/null 2>&1; then echo "   [ok] $c"; else echo "   [miss] $c"; missing=1; fi
  done
  echo "   rootfs: $ROOTFS_DIR"
  if [ "$missing" -ne 0 ]; then return 1; fi
  echo "==> সব টুল উপস্থিত"
}

cmd_iso() {
  require_root

  if [ ! -d "$ROOTFS_DIR" ] || [ -z "$(ls -A "$ROOTFS_DIR")" ]; then
    err "রুটফাইলসিস্টেম খালি/নেই — আগে build/00-debootstrap.sh bootstrap চালান"
    return 1
  fi
  require_cmd mksquashfs
  require_cmd grub-mkrescue
  require_cmd xorriso

  step "১. অস্থায়ী আইএসও ডিরেক্টরি প্রস্তুতি ($ISO_DIR)"
  rm -rf "$ISO_DIR"
  mkdir -p "$ISO_DIR/live"

  step "২. রুটফাইলসিস্টেম থেকে squashfs ($ISO_DIR/live/filesystem.squashfs)"
  mksquashfs "$ROOTFS_DIR" "$ISO_DIR/live/filesystem.squashfs" -comp xz

  step "৩. কার্নেল + ইনিটরেডিইম কপি (rootfs/boot → iso/live)"
  VMLINUZ="$(ls "$ROOTFS_DIR"/boot/vmlinuz-* 2>/dev/null | head -1)"
  INITRD="$(ls "$ROOTFS_DIR"/boot/initrd.img-* 2>/dev/null | head -1)"
  if [ -z "$VMLINUZ" ] || [ -z "$INITRD" ]; then
    err "কার্নেল/ইনিটরেডিইম পাওয়া যায়নি (rootfs/boot/) — আগে linux-image-amd64 ইনস্টল করুন"
    return 1
  fi
  cp "$VMLINUZ" "$ISO_DIR/live/vmlinuz"
  cp "$INITRD" "$ISO_DIR/live/initrd.img"

  step "৪. GRUB কনফিগারেশন (iso/boot/grub/grub.cfg)"
  mkdir -p "$ISO_DIR/boot/grub"
  cat > "$ISO_DIR/boot/grub/grub.cfg" <<'EOF'
set default=0
set timeout=5

menuentry "Sayanox OS (Live)" {
  set gfxpayload=keep
  linux   /live/vmlinuz boot=live components quiet splash
  initrd  /live/initrd.img
}
EOF

  step "৫. GRUB + xorriso দিয়ে আইএসও তৈরি ($ISO_FILE)"
  grub-mkrescue -o "$ISO_FILE" "$ISO_DIR"

  step "আইএসও রady: $ISO_FILE"
  echo "   কিউইএমে টেস্ট: qemu-system-x86_64 -cdrom $ISO_FILE -m 2048"
  echo "   ইউএফআই/সিকিউর বুট: পর্ব ৩ (Calamares + ডেবিয়ান সাইনড শিম)"
}

usage() {
  cat <<EOF
ব্যবহার: $0 {iso|check}
  iso   - sayanox-0.0.1.iso তৈরি (sqaushfs + GRUB)
  check - বিল্ড পরিবেশ যাচাই
EOF
}

main() {
  case "${1:-}" in
    iso)  cmd_iso ;;
    check) cmd_check ;;
    *)    usage; exit 1 ;;
  esac
}

main "$@"
