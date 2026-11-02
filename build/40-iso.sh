#!/usr/bin/env bash
#
# build/40-iso.sh — Sayanox OS Phase 1: বুটেবল লাইভ ISO (GRUB + squashfs)
# শুধু BIOS (i386-pc) — UEFI+Secure Boot ফেজ ৩-এ (ডেবিয়ার সাইনড শিম)।
#
# prerequisite: rootfs-এ কernel (linux-image-amd64) এবং initramfs থাকতে হবে।
#
# ব্যবহার:
#   sudo ./build/40-iso.sh <rootfs_dir> <squashfs> <output.iso> check
#   sudo ./build/40-iso.sh <rootfs_dir> <squashfs> <output.iso> apply
#
set -euo pipefail

ROOTFS="${1:-}"
SQUASH="${2:-}"
OUT="${3:-}"
MODE="${4:-apply}"
ISO_ROOT="$(mktemp -d)/sayanox-iso"

fail() { echo "!! $*" >&2; exit 1; }
step() { echo "==> $*"; }

cmd_check() {
  echo "==> 40-iso চেক"
  local missing=0
  for c in grub-mkrescue xorriso cp install; do
    command -v "$c" >/dev/null 2>&1 || { echo "   [miss] $c"; missing=1; }
  done
  [ -f "$SQUASH" ] || { echo "   [miss] squashfs ফাইল: $SQUASH (পূর্বে build/30-squashfs.sh চালান)"; missing=1; }
  [ -n "$ROOTFS" ] && [ -d "$ROOTFS" ] || { echo "   [miss] রুটফাইলসিস্টেম"; missing=1; }
  [ "$missing" -eq 0 ] || fail "40-iso: টুল/ইনপুট অনুপস্থিত।"
  echo "   [ok] গ্রাব-মməkরেসু / xogriso এবং ইনপুট উপস্থিত"
}

cmd_apply() {
  [ -n "$ROOTFS" ] && [ -d "$ROOTFS" ] || fail "ব্যবহার: $0 <rootfs_dir> <squashfs> <output.iso> apply"
  [ -f "$SQUASH" ] || fail "squashfs ফাইল পাওয়া যায়নি: $SQUASH"
  [ -n "$OUT" ] || fail "আউটপুট ISO পাথ দিন"
  rm -rf "$ISO_ROOT"; mkdir -p "$ISO_ROOT/boot/grub" "$ISO_ROOT/live"

  step "সquashfs কপি → live/filesystem.squashfs"
  cp "$SQUASH" "$ISO_ROOT/live/filesystem.squashfs"

  step "কernel + initrd কপি → boot/"
  KERNEL="$(ls "$ROOTFS"/boot/vmlinuz-* 2>/dev/null | head -1)"
  INITRD="$(ls "$ROOTFS"/boot/initrd.img-* 2>/dev/null | head -1)"
  [ -n "$KERNEL" ] || fail "রুটফাইলসিস্টেমে বুটযোগ্য কernel নেই (linux-image-amd64 ইনস্টল করুন)"
  [ -n "$INITRD" ] || fail "রুটফাইলসিস্টেমে initrd নেই (initramfs-tools ইনস্টল করুন)"
  cp "$KERNEL" "$ISO_ROOT/boot/vmlinuz"
  cp "$INITRD" "$ISO_ROOT/boot/initrd.img"

  step "GRUB কনফিগারেশন"
  cat > "$ISO_ROOT/boot/grub/grub.cfg" <<EOF
set default=0
set timeout=5

menuentry "Sayanox OS (Live)" {
  linux   /boot/vmlinuz boot=live quiet splash
  initrd  /boot/initrd.img
}
EOF

  step "ISO তৈরি: $OUT (grub-mkrescue)"
  grub-mkrescue -o "$OUT" "$ISO_ROOT" || xorriso -as mkisofs -o "$OUT" -b boot/grub/i386-pc/eltorito.img \
    -no-emul-boot -boot-load-size 4 -boot-info-table "$ISO_ROOT"

  rm -rf "$(dirname "$ISO_ROOT")"
  step "ISO রady: $OUT"
  echo "   কিউইএমে টেস্ট: qemu-system-x86_64 -cdrom $OUT -m 2048"
}

case "$MODE" in
  check) cmd_check ;;
  apply) cmd_apply ;;
  *)     echo "ব্যবহার: $0 <rootfs_dir> <squashfs> <output.iso> {check|apply}" >&2; exit 1 ;;
esac
