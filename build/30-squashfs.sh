#!/usr/bin/env bash
#
# build/30-squashfs.sh — Sayanox OS Phase 1: রুটফাইলসিস্টেম থেকে squashfs তৈরি
# লাইভ আইএসওয়ের জন্য 'live/filesystem.squashfs'।
#
# ব্যবহার:
#   sudo ./build/30-squashfs.sh <rootfs_dir> <output.squashfs> check
#   sudo ./build/30-squashfs.sh <rootfs_dir> <output.squashfs> apply
#
set -euo pipefail

ROOTFS="${1:-}"
OUT="${2:-}"
MODE="${3:-apply}"

fail() { echo "!! $*" >&2; exit 1; }
step() { echo "==> $*"; }

cmd_check() {
  echo "==> 30-squashfs চেক"
  command -v mksquashfs >/dev/null 2>&1 || fail "mksquashfs পাওয়া যায়নি (squashfs-tools ইনস্টল করুন)"
  [ -n "$ROOTFS" ] && [ -d "$ROOTFS" ] || fail "রুটফাইলসিস্টেম ডিরেক্টরি দিন"
  echo "   [ok] mksquashfs উপস্থিত, রুটফাইলসিস্টেম: $ROOTFS"
}

cmd_apply() {
  [ -n "$ROOTFS" ] && [ -d "$ROOTFS" ] || fail "ব্যবহার: $0 <rootfs_dir> <output.squashfs> apply"
  [ -n "$OUT" ] || fail "আউটপুট squashfs পাথ দিন"
  mkdir -p "$(dirname "$OUT")"

  step "squashfs তৈরি: $OUT (কম্প্রেশন xz)"
  mksquashfs "$ROOTFS" "$OUT" -comp xz -xdev \
    -e "$ROOTFS/proc" -e "$ROOTFS/sys" -e "$ROOTFS/dev" -e "$ROOTFS/run" \
    -e "$ROOTFS/tmp" -e "$ROOTFS/var/run" -e "$ROOTFS/var/lock"

  step "squashfs রady: $OUT"
  echo "   পরের ধাপ: build/40-iso.sh (কernel+initrd+grub + এই squashfs → ISO)"
}

case "$MODE" in
  check) cmd_check ;;
  apply) cmd_apply ;;
  *)     echo "ব্যবহার: $0 <rootfs_dir> <output.squashfs> {check|apply}" >&2; exit 1 ;;
esac
