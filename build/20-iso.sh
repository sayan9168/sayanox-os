#!/usr/bin/env bash
#
# build/20-iso.sh — Sayanox OS Phase 1
# squashfs + GRUB -> sayanox-0.0.1.iso (live ISO, bootable)
#
# Requirements (build host): root/sudo, mksquashfs, grub-mkrescue, xorriso, grub-pc
#   grub-efi-amd64 binary needed for UEFI boot (UEFI + Secure Boot planned for Phase 3)
#
# Usage:
#   sudo ./build/20-iso.sh iso      # build sayanox-0.0.1.iso
#   sudo ./build/20-iso.sh check    # check tools
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
  [ "$(id -u)" -eq 0 ] || { err "This step requires root (run with sudo)"; return 1; }
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || { err "Required command not found: $1"; return 1; }
}

cmd_check() {
  echo "==> Sayanox OS Phase 1 (ISO) environment check"
  local missing=0
  for c in mksquashfs grub-mkrescue xorriso; do
    if command -v "$c" >/dev/null 2>&1; then echo "   [ok] $c"; else echo "   [miss] $c"; missing=1; fi
  done
  echo "   rootfs: $ROOTFS_DIR"
  if [ "$missing" -ne 0 ]; then return 1; fi
  echo "==> All tools present"
}

cmd_iso() {
  require_root

  if [ ! -d "$ROOTFS_DIR" ] || [ -z "$(ls -A "$ROOTFS_DIR")" ]; then
    err "Rootfs missing/empty — run build/00-debootstrap.sh bootstrap first"
    return 1
  fi
  require_cmd mksquashfs
  require_cmd grub-mkrescue
  require_cmd xorriso

  step "1. Prepare temporary ISO directory ($ISO_DIR)"
  rm -rf "$ISO_DIR"
  mkdir -p "$ISO_DIR/live"

  step "2. Build squashfs from rootfs ($ISO_DIR/live/filesystem.squashfs)"
  mksquashfs "$ROOTFS_DIR" "$ISO_DIR/live/filesystem.squashfs" -comp xz

  step "3. Copy kernel + initrd (rootfs/boot -> iso/live)"
  VMLINUZ="$(ls "$ROOTFS_DIR"/boot/vmlinuz-* 2>/dev/null | head -1)"
  INITRD="$(ls "$ROOTFS_DIR"/boot/initrd.img-* 2>/dev/null | head -1)"
  if [ -z "$VMLINUZ" ] || [ -z "$INITRD" ]; then
    err "Kernel/initrd not found (rootfs/boot/) — install linux-image-amd64 first"
    return 1
  fi
  cp "$VMLINUZ" "$ISO_DIR/live/vmlinuz"
  cp "$INITRD" "$ISO_DIR/live/initrd.img"

  step "4. GRUB configuration (iso/boot/grub/grub.cfg)"
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

  step "5. Build ISO with GRUB + xorriso ($ISO_FILE)"
  grub-mkrescue -o "$ISO_FILE" "$ISO_DIR"

  step "ISO ready: $ISO_FILE"
  echo "   Test in QEMU: qemu-system-x86_64 -cdrom $ISO_FILE -m 2048"
  echo "   UEFI/Secure Boot: Phase 3 (Calamares + Debian signed shim)"
}

usage() {
  cat <<EOF
Usage: $0 {iso|check}
  iso   - build sayanox-0.0.1.iso (squashfs + GRUB)
  check - check build environment
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
